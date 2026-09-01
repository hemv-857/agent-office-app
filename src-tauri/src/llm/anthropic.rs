use crate::error::AppError;
use crate::llm::{LLMRequest, LLMResponse, Provider, StreamChunk};
use async_trait::async_trait;
use futures::StreamExt;
use std::sync::mpsc;
use std::time::Duration;
use tracing::{debug, info};

#[derive(Debug)]
pub struct AnthropicProvider;

#[async_trait]
impl Provider for AnthropicProvider {
    fn name(&self) -> &str {
        "anthropic"
    }

    fn default_model(&self) -> &str {
        "claude-sonnet-4-20250514"
    }

    fn validate_key(&self, key: &str) -> bool {
        key.starts_with("sk-ant-")
    }

    fn calculate_cost(&self, model: &str, input: u32, output: u32) -> f64 {
        let (input_price, output_price) = match model {
            "claude-sonnet-4-20250514" => (3.0 / 1_000_000.0, 15.0 / 1_000_000.0),
            "claude-3-5-sonnet-20241022" => (3.0 / 1_000_000.0, 15.0 / 1_000_000.0),
            "claude-3-5-haiku-20241022" => (0.80 / 1_000_000.0, 4.0 / 1_000_000.0),
            _ => (3.0 / 1_000_000.0, 15.0 / 1_000_000.0),
        };
        (input as f64 * input_price) + (output as f64 * output_price)
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

        let model = request
            .model
            .unwrap_or_else(|| self.default_model().to_string());
        let max_tokens = request.max_tokens.unwrap_or(4096);

        debug!(model, max_tokens, "Sending Anthropic request");

        let body = serde_json::json!({
            "model": model,
            "max_tokens": max_tokens,
            "system": request.system_prompt,
            "messages": [
                {"role": "user", "content": request.user_prompt}
            ],
            "stream": true
        });

        let response = client
            .post("https://api.anthropic.com/v1/messages")
            .header("x-api-key", api_key)
            .header("anthropic-version", "2023-06-01")
            .header("content-type", "application/json")
            .json(&body)
            .send()
            .await?;

        let status = response.status();
        if !status.is_success() {
            let body_text = response.text().await.unwrap_or_default();
            if status.as_u16() == 429 {
                let retry_after = extract_retry_after(&body_text);
                return Err(AppError::RateLimited {
                    provider: "anthropic".into(),
                    retry_after_ms: retry_after,
                });
            }
            return Err(AppError::LlmApi {
                status: status.as_u16(),
                body: body_text,
            });
        }

        let mut full_text = String::new();
        let mut input_tokens = 0u32;
        let mut output_tokens = 0u32;

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
                    match json["type"].as_str() {
                        Some("content_block_delta") => {
                            if let Some(text) = json["delta"]["text"].as_str() {
                                full_text.push_str(text);
                                let _ = tx.send(StreamChunk {
                                    text: text.to_string(),
                                    done: false,
                                    tokens_used: None,
                                });
                            }
                        }
                        Some("message_start") => {
                            input_tokens = json["message"]["usage"]["input_tokens"]
                                .as_u64()
                                .unwrap_or(0) as u32;
                        }
                        Some("message_delta") => {
                            output_tokens = json["delta"]["usage"]["output_tokens"]
                                .as_u64()
                                .unwrap_or(0) as u32;
                        }
                        _ => {}
                    }
                }
            }
        }

        let _ = tx.send(StreamChunk {
            text: String::new(),
            done: true,
            tokens_used: Some(output_tokens),
        });

        let cost = self.calculate_cost(&model, input_tokens, output_tokens);
        info!(model, input_tokens, output_tokens, cost, "Anthropic request complete");

        Ok(LLMResponse {
            text: full_text,
            input_tokens,
            output_tokens,
            model,
            cost_usd: cost,
            provider: "anthropic".into(),
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
