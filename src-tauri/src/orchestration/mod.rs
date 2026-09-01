use crate::agent::{Agent, AgentRegistry};
use crate::llm::LLMRequest;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskRequest {
    pub prompt: String,
    pub agent_ids: Vec<String>,
    pub provider: String,
    pub model: Option<String>,
    pub temperature: Option<f32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskResult {
    pub session_id: String,
    pub agent_results: Vec<AgentResult>,
    pub total_cost_usd: f64,
    pub total_tokens: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentResult {
    pub agent_id: String,
    pub agent_name: String,
    pub response: String,
    pub tokens_used: u32,
    pub cost_usd: f64,
    pub status: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamEvent {
    pub session_id: String,
    pub agent_id: String,
    pub event_type: String, // "chunk", "done", "error"
    pub text: String,
    pub tokens_used: Option<u32>,
    pub cost_usd: Option<f64>,
}

pub struct Orchestrator {
    registry: AgentRegistry,
}

impl Orchestrator {
    pub fn new(registry: AgentRegistry) -> Self {
        Self { registry }
    }

    pub fn all_agents(&self) -> &[Agent] {
        &self.registry.agents
    }

    pub fn search_agents(&self, query: &str) -> Vec<&Agent> {
        self.registry.search(query)
    }

    pub fn get_agent(&self, id: &str) -> Option<&Agent> {
        self.registry.get(id)
    }

    pub fn build_request(
        &self,
        agent: &Agent,
        prompt: &str,
        model: Option<&str>,
        temperature: Option<f32>,
    ) -> LLMRequest {
        LLMRequest {
            system_prompt: agent.system_prompt.clone(),
            user_prompt: prompt.to_string(),
            model: model.map(|s| s.to_string()),
            max_tokens: Some(4096),
            temperature,
        }
    }
}
