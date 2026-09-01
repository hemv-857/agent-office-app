use serde::Serialize;

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("Agent '{id}' not found")]
    AgentNotFound { id: String },

    #[error("No API key for provider '{provider}'. Open Settings to add one.")]
    MissingApiKey { provider: String },

    #[error("Unknown provider: {0}")]
    UnknownProvider(String),

    #[error("Failed to parse agent suggestion response: {message}\nRaw: {raw}")]
    AgentSuggestionParse { message: String, raw: String },

    #[error("Pipeline failed at agent '{agent_name}' ({agent_id}): {reason}")]
    PipelineFailed {
        agent_name: String,
        agent_id: String,
        reason: String,
    },

    #[error("HTTP request failed: {0}")]
    Http(#[from] reqwest::Error),

    #[error("JSON error: {0}")]
    Json(#[from] serde_json::Error),

    #[error("LLM API error ({status}): {body}")]
    LlmApi { status: u16, body: String },

    #[error("Stream read error: {0}")]
    StreamRead(String),

    #[error("Rate limited by {provider}, retry after {retry_after_ms}ms")]
    RateLimited {
        provider: String,
        retry_after_ms: u64,
    },

    #[error("Request timeout after {ms}ms")]
    Timeout { ms: u64 },

    #[error("Agents registry failed to load: {0}")]
    RegistryLoad(String),
}

impl Serialize for AppError {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(&self.to_string())
    }
}

impl From<AppError> for String {
    fn from(e: AppError) -> String {
        e.to_string()
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct AgentInfo {
    pub id: String,
    pub name: String,
    pub division: String,
    pub description: String,
    pub office_role: String,
    pub emoji: String,
}

#[derive(Debug, Clone, Serialize)]
pub struct AgentDetailInfo {
    pub id: String,
    pub name: String,
    pub division: String,
    pub description: String,
    pub office_role: String,
    pub emoji: String,
    pub system_prompt: String,
}

#[derive(Debug, Clone, Serialize, serde::Deserialize)]
pub struct SuggestedAgents {
    pub agent_ids: Vec<String>,
    pub reasoning: String,
}
