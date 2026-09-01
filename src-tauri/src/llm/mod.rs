pub mod anthropic;
pub mod openai;
pub mod registry;

use crate::error::AppError;
use serde::{Deserialize, Serialize};
use std::sync::mpsc;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LLMRequest {
    pub system_prompt: String,
    pub user_prompt: String,
    pub model: Option<String>,
    pub max_tokens: Option<u32>,
    pub temperature: Option<f32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LLMResponse {
    pub text: String,
    pub input_tokens: u32,
    pub output_tokens: u32,
    pub model: String,
    pub cost_usd: f64,
    pub provider: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamChunk {
    pub text: String,
    pub done: bool,
    pub tokens_used: Option<u32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProviderConfig {
    pub name: String,
    pub default_model: String,
    pub api_key: Option<String>,
    pub max_retries: u32,
    pub timeout_secs: u64,
}

impl Default for ProviderConfig {
    fn default() -> Self {
        Self {
            name: String::new(),
            default_model: String::new(),
            api_key: None,
            max_retries: 3,
            timeout_secs: 300,
        }
    }
}

/// Trait for LLM providers. Implement this to add new providers.
#[async_trait::async_trait]
pub trait Provider: Send + Sync + std::fmt::Debug {
    fn name(&self) -> &str;
    fn default_model(&self) -> &str;
    fn validate_key(&self, key: &str) -> bool;

    async fn execute(
        &self,
        request: LLMRequest,
        api_key: &str,
        tx: mpsc::Sender<StreamChunk>,
    ) -> Result<LLMResponse, AppError>;

    fn calculate_cost(&self, model: &str, input_tokens: u32, output_tokens: u32) -> f64;
}
