use crate::error::AppError;
use crate::llm::{LLMRequest, LLMResponse, Provider, StreamChunk};
use async_trait::async_trait;
use futures::StreamExt;
use std::sync::mpsc;
use std::time::Duration;
use tracing::{debug, info};

#[derive(Debug)]
pub struct OpenAIProvider;

#[async_trait]
impl Provider for OpenAIProvider {
    fn name(&self) -> &str {
        "openai"
    }

    fn default_model(&self) -> &str {
        "gpt-4o"
    }

    fn validate_key(&self, key: &str) -> bool {
        key.starts_with("sk-")
    }

    fn calculate_cost(&self, model: &str, input_tokens: u32, output_tokens: u32) -> f64 {
        let tokens = input_tokens + output_tokens;
        let price_per_token = match model {
            "gpt-4o" => 2.5 / 1_000_000.0,
            "gpt-4o-mini" => 0.15 / 1_000_000.0,
            "gpt-4-turbo" => 10.0 / 1_000_000.0,
            _ => 2.5 / 1_000_000.0,
        };
        tokens as f64 * price_per_token
    }

    async fn execute(
        &self,
        request: LLMRequest,
        api_key: &str,
        tx: mpsc::Sender<StreamChunk>,
    ) -> Result<LLMResponse, AppError> {
        let client = reqwest::Client::builder()
            .timeout(Duration::from_secs(300))
            .build()?;

        let model = request.model.unwrap_or_else(|| self.default_model().to_string());

        debug!(model, "Sending OpenAI request");

        let body = serde_json::json!({
            "model": model,
            "messages": [
                {"role": "system", "content": request.system_prompt},
                {"role": "user", "content": request.user_prompt}
            ],
            "max_tokens": request.max_tokens.unwrap_or(4096),
            "temperature": request.temperature.unwrap_or(0.7),
            "stream": true
        });

        let response = client
            .post("https://api.openai.com/v1/chat/completions")
            .header("Authorization", format!("Bearer {}", api_key))
            .header("Content-Type", "application/json")
            .json(&body)
            .send()
            .await?;

        let status = response.status();
        if !status.is_success() {
            let body_text = response.text().await.unwrap_or_default();
            if status.as_u16() == 429 {
                let retry_after = extract_retry_after(&body_text);
                return Err(AppError::RateLimited {
                    provider: "openai".into(),
                    retry_after_ms: retry_after,
                });
            }
            return Err(AppError::LlmApi {
                status: status.as_u16(),
                body: body_text,
            });
        }

        let mut full_text = String::new();
        let mut total_tokens = 0u32;

        let mut stream = response.bytes_stream();
        let mut buffer = String::new();

        while let Some(chunk) = stream.next().await {
            let chunk = chunk.map_err(|e| AppError::StreamRead(e.to_string()))?;
            buffer.push_str(&String::from_utf8_lossy(&chunk));

            while let Some(line_end) = buffer.find('\n') {
                let line = buffer[..line_end].trim().to_string();
                buffer = buffer[line_end + 1..].to_string();

                if line.is_empty() || !line.starts_with("data: ") {
                    continue;
                }

                let data = &line[6..];
                if data == "[DONE]" {
                    break;
                }

                if let Ok(json) = serde_json::from_str::<serde_json::Value>(data) {
                    if let Some(delta) = json["choices"][0]["delta"]["content"].as_str() {
                        full_text.push_str(delta);
                        let _ = tx.send(StreamChunk {
                            text: delta.to_string(),
                            done: false,
                            tokens_used: None,
                        });
                    }
                    if let Some(usage) = json["usage"]["total_tokens"].as_u64() {
                        total_tokens = usage as u32;
                    }
                }
            }
        }

        let _ = tx.send(StreamChunk {
            text: String::new(),
            done: true,
            tokens_used: Some(total_tokens),
        });

        let cost = self.calculate_cost(&model, total_tokens / 2, total_tokens / 2);
        info!(model, total_tokens, cost, "OpenAI request complete");

        Ok(LLMResponse {
            text: full_text,
            input_tokens: total_tokens / 2,
            output_tokens: total_tokens / 2,
            model,
            cost_usd: cost,
            provider: "openai".into(),
        })
    }
}

fn extract_retry_after(body: &str) -> u64 {
    serde_json::from_str::<serde_json::Value>(body)
        .ok()
        .and_then(|v| v["error"]["message"].as_str().map(|s| s.to_string()))
        .and_then(|msg| {
            msg.split("retry after")
                .nth(1)?
                .split_whitespace()
                .next()?
                .parse::<u64>()
                .ok()
                .map(|s| s * 1000)
        })
        .unwrap_or(5000)
}
