use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Agent {
    pub id: String,
    pub name: String,
    pub division: String,
    pub description: String,
    #[serde(rename = "systemPrompt")]
    pub system_prompt: String,
    #[serde(rename = "officeRole")]
    pub office_role: String,
    pub emoji: String,
    pub tags: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentRegistry {
    pub agents: Vec<Agent>,
    #[serde(rename = "generatedAt")]
    pub generated_at: String,
}

impl AgentRegistry {
    pub fn load(json: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json)
    }

    pub fn get(&self, id: &str) -> Option<&Agent> {
        self.agents.iter().find(|a| a.id == id)
    }

    pub fn search(&self, query: &str) -> Vec<&Agent> {
        let q = query.to_lowercase();
        self.agents
            .iter()
            .filter(|a| {
                a.name.to_lowercase().contains(&q)
                    || a.division.to_lowercase().contains(&q)
                    || a.description.to_lowercase().contains(&q)
                    || a.tags.iter().any(|t| t.to_lowercase().contains(&q))
            })
            .collect()
    }

    pub fn by_division(&self, division: &str) -> Vec<&Agent> {
        self.agents
            .iter()
            .filter(|a| a.division == division)
            .collect()
    }

    pub fn by_role(&self, role: &str) -> Vec<&Agent> {
        self.agents
            .iter()
            .filter(|a| a.office_role == role)
            .collect()
    }
}
