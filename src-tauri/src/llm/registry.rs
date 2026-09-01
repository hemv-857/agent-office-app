use crate::error::AppError;
use crate::llm::anthropic::AnthropicProvider;
use crate::llm::openai::OpenAIProvider;
use crate::llm::{LLMRequest, LLMResponse, Provider, StreamChunk};
use std::collections::HashMap;
use std::sync::mpsc;
use std::sync::{Arc, RwLock};
use std::time::Duration;
use tracing::{debug, warn};

const MAX_RETRIES: u32 = 3;
const BASE_BACKOFF_MS: u64 = 1000;

pub struct ProviderRegistry {
    providers: HashMap<String, Arc<dyn Provider>>,
    api_keys: RwLock<HashMap<String, String>>,
}

impl ProviderRegistry {
    pub fn new() -> Self {
        let mut providers: HashMap<String, Arc<dyn Provider>> = HashMap::new();
        providers.insert("anthropic".into(), Arc::new(AnthropicProvider));
        providers.insert("openai".into(), Arc::new(OpenAIProvider));

        Self {
            providers,
            api_keys: RwLock::new(HashMap::new()),
        }
    }

    pub fn register(&mut self, name: String, provider: Arc<dyn Provider>) {
        self.providers.insert(name, provider);
    }

    pub fn set_api_key(&self, provider: &str, key: String) {
        let mut keys = self.api_keys.write().unwrap();
        if !key.is_empty() {
            keys.insert(provider.to_string(), key);
        }
    }

    pub fn has_api_key(&self, provider: &str) -> bool {
        let keys = self.api_keys.read().unwrap();
        keys.get(provider).map(|k| !k.is_empty()).unwrap_or(false)
    }

    pub fn get_provider(&self, name: &str) -> Result<Arc<dyn Provider>, AppError> {
        self.providers
            .get(name)
            .cloned()
            .ok_or_else(|| AppError::UnknownProvider(name.to_string()))
    }

    pub fn list_providers(&self) -> Vec<String> {
        self.providers.keys().cloned().collect()
    }

    pub async fn execute(
        &self,
        provider_name: &str,
        request: LLMRequest,
        tx: mpsc::Sender<StreamChunk>,
    ) -> Result<LLMResponse, AppError> {
        let provider = self.get_provider(provider_name)?;
        let api_key = {
            let keys = self.api_keys.read().unwrap();
            keys.get(provider_name)
                .cloned()
                .ok_or_else(|| AppError::MissingApiKey {
                    provider: provider_name.to_string(),
                })?
        };

        let mut last_err: Option<AppError> = None;

        for attempt in 0..=MAX_RETRIES {
            match provider
                .execute(request.clone(), &api_key, tx.clone())
                .await
            {
                Ok(response) => return Ok(response),
                Err(e) => {
                    if attempt < MAX_RETRIES && is_retryable(&e) {
                        let backoff = BASE_BACKOFF_MS * 2u64.saturating_pow(attempt);
                        warn!(
                            provider = provider_name,
                            attempt,
                            backoff_ms = backoff,
                            error = %e,
                            "Retrying after error"
                        );
                        tokio::time::sleep(Duration::from_millis(backoff)).await;
                        last_err = Some(e);
                    } else {
                        return Err(e);
                    }
                }
            }
        }

        Err(last_err.unwrap_or_else(|| AppError::StreamRead("Exhausted retries".into())))
    }

    pub async fn execute_with_fallback(
        &self,
        preferred_provider: &str,
        request: LLMRequest,
        tx: mpsc::Sender<StreamChunk>,
    ) -> Result<LLMResponse, AppError> {
        // Try preferred provider first
        match self.execute(preferred_provider, request.clone(), tx.clone()).await {
            Ok(response) => Ok(response),
            Err(e) if is_fatal(&e) => {
                // Try fallback providers
                for name in self.list_providers() {
                    if name != preferred_provider && self.has_api_key(&name) {
                        debug!(from = preferred_provider, to = %name, "Falling back to alternative provider");
                        if let Ok(resp) = self.execute(&name, request.clone(), tx.clone()).await {
                            return Ok(resp);
                        }
                    }
                }
                Err(e)
            }
            Err(e) => Err(e),
        }
    }
}

fn is_retryable(err: &AppError) -> bool {
    match err {
        AppError::RateLimited { .. } => true,
        AppError::Timeout { .. } => true,
        AppError::Http(e) => {
            e.status()
                .map(|s| s == 429 || s.is_server_error())
                .unwrap_or(false)
        }
        _ => false,
    }
}

fn is_fatal(err: &AppError) -> bool {
    matches!(err, AppError::MissingApiKey { .. } | AppError::LlmApi { status: 401, .. })
}

#[cfg(test)]
#[allow(dead_code)]
mod tests {
    use super::*;
    use crate::llm::{LLMRequest, Provider, StreamChunk};
    use std::sync::mpsc;

#[derive(Debug)]
struct MockProvider {
    name: String,
    should_fail: bool,
    response: LLMResponse,
}

    impl MockProvider {
        fn new(name: &str, should_fail: bool) -> Self {
            Self {
                name: name.to_string(),
                should_fail,
                response: LLMResponse {
                    text: "test response".to_string(),
                    input_tokens: 10,
                    output_tokens: 20,
                    model: "test-model".to_string(),
                    cost_usd: 0.001,
                    provider: name.to_string(),
                },
            }
        }
    }

    #[async_trait::async_trait]
    impl Provider for MockProvider {
        fn name(&self) -> &str {
            &self.name
        }

        fn default_model(&self) -> &str {
            "test-model"
        }

        fn validate_key(&self, _key: &str) -> bool {
            true
        }

        fn calculate_cost(&self, _model: &str, input: u32, output: u32) -> f64 {
            (input + output) as f64 * 0.00001
        }

        async fn execute(
            &self,
            _request: LLMRequest,
            _api_key: &str,
            tx: mpsc::Sender<StreamChunk>,
        ) -> Result<LLMResponse, AppError> {
            if self.should_fail {
                // Use a simple error instead of trying to construct reqwest::Error
                return Err(AppError::StreamRead("mock error".to_string()));
            }
            let _ = tx.send(StreamChunk { text: "test".to_string(), done: true, tokens_used: Some(20) });
            Ok(self.response.clone())
        }
    }

    #[tokio::test]
    async fn test_registry_creation() {
        let registry = ProviderRegistry::new();
        let providers = registry.list_providers();
        assert!(providers.contains(&"anthropic".to_string()));
        assert!(providers.contains(&"openai".to_string()));
    }

    #[tokio::test]
    async fn test_api_key_management() {
        let registry = ProviderRegistry::new();
        assert!(!registry.has_api_key("anthropic"));
        assert!(!registry.has_api_key("openai"));

        registry.set_api_key("anthropic", "sk-ant-test".to_string());
        assert!(registry.has_api_key("anthropic"));
        assert!(!registry.has_api_key("openai"));

        registry.set_api_key("openai", "sk-test".to_string());
        assert!(registry.has_api_key("openai"));
    }

    #[tokio::test]
    async fn test_get_unknown_provider() {
        let registry = ProviderRegistry::new();
        let result = registry.get_provider("unknown");
        assert!(result.is_err());
        assert!(matches!(result.unwrap_err(), AppError::UnknownProvider(_)));
    }

    #[tokio::test]
    async fn test_is_retryable() {
        // Rate limited is retryable
        assert!(is_retryable(&AppError::RateLimited {
            provider: "test".into(),
            retry_after_ms: 1000,
        }));

        // Timeout is retryable
        assert!(is_retryable(&AppError::Timeout { ms: 5000 }));

        // Stream read error is not retryable
        assert!(!is_retryable(&AppError::StreamRead("error".into())));

        // Missing API key is not retryable
        assert!(!is_retryable(&AppError::MissingApiKey {
            provider: "test".into(),
        }));

        // LlmApi error is not retryable (default)
        assert!(!is_retryable(&AppError::LlmApi {
            status: 500,
            body: "server error".into(),
        }));

        // But 429 should be retryable (handled by RateLimited variant)
        // Unknown provider not retryable
        assert!(!is_retryable(&AppError::UnknownProvider("test".into())));
    }

    #[tokio::test]
    async fn test_is_fatal() {
        assert!(is_fatal(&AppError::MissingApiKey {
            provider: "test".into(),
        }));

        assert!(is_fatal(&AppError::LlmApi {
            status: 401,
            body: "unauthorized".into(),
        }));

        assert!(!is_fatal(&AppError::LlmApi {
            status: 500,
            body: "server error".into(),
        }));

        assert!(!is_fatal(&AppError::RateLimited {
            provider: "test".into(),
            retry_after_ms: 1000,
        }));
    }
}
