use agent_office_lib::agent::AgentRegistry;
use agent_office_lib::error::{AppError, AgentInfo, AgentDetailInfo, SuggestedAgents};
use agent_office_lib::llm::registry::ProviderRegistry;
use agent_office_lib::llm::LLMRequest;
use agent_office_lib::orchestration::{Orchestrator, StreamEvent, TaskRequest};
use serde::{Serialize, Deserialize};
use std::collections::HashMap;
use std::process::Command as StdCommand;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, RwLock};
use tauri::{Emitter, State};
use tracing::{info, error};
use tracing_subscriber::EnvFilter;

struct AppState {
    orchestrator: Orchestrator,
    registry: Arc<ProviderRegistry>,
    active_sessions: RwLock<HashMap<String, Arc<AtomicBool>>>,
}

impl AppState {
    fn resolve_agents(
        &self,
        agent_ids: &[String],
    ) -> Result<Vec<(String, String, String)>, AppError> {
        agent_ids
            .iter()
            .map(|id| {
                let agent = self.orchestrator.get_agent(id).ok_or_else(|| {
                    AppError::AgentNotFound {
                        id: id.to_string(),
                    }
                })?;
                Ok((id.clone(), agent.system_prompt.clone(), agent.name.clone()))
            })
            .collect()
    }
}

#[tauri::command]
fn get_agents(state: State<AppState>) -> Vec<AgentInfo> {
    state
        .orchestrator
        .all_agents()
        .iter()
        .map(|a| AgentInfo {
            id: a.id.clone(),
            name: a.name.clone(),
            division: a.division.clone(),
            description: a.description.clone(),
            office_role: a.office_role.clone(),
            emoji: a.emoji.clone(),
        })
        .collect()
}

#[tauri::command]
fn search_agents(state: State<AppState>, query: String) -> Vec<AgentInfo> {
    state
        .orchestrator
        .search_agents(&query)
        .iter()
        .map(|a| AgentInfo {
            id: a.id.clone(),
            name: a.name.clone(),
            division: a.division.clone(),
            description: a.description.clone(),
            office_role: a.office_role.clone(),
            emoji: a.emoji.clone(),
        })
        .collect()
}

#[tauri::command]
async fn execute_task(
    state: State<'_, AppState>,
    request: TaskRequest,
    app: tauri::AppHandle,
) -> Result<String, AppError> {
    let session_id = uuid::Uuid::new_v4().to_string();
    let cancel_token = Arc::new(AtomicBool::new(false));

    // Register cancellation token
    {
        if let Ok(mut sessions) = state.active_sessions.write() {
            sessions.insert(session_id.clone(), cancel_token.clone());
        }
    }

    info!(session_id = %session_id, agents = ?request.agent_ids, "Executing task");

    let agent_ids = request.agent_ids.clone();
    let prompt = request.prompt.clone();
    let provider_name = request.provider.clone();
    let model = request.model.clone();
    let temperature = request.temperature;

    let agent_details = state.resolve_agents(&agent_ids)?;

    let handles: Vec<_> = agent_details
        .into_iter()
        .map(|(agent_id, system_prompt, _agent_name)| {
            let registry = state.registry.clone();
            let provider_name = provider_name.clone();
            let app_handle = app.clone();
            let sid = session_id.clone();
            let aid = agent_id.clone();
            let prompt_clone = prompt.clone();
            let model_clone = model.clone();
            let cancel = cancel_token.clone();

            tokio::spawn(async move {
                let llm_request = LLMRequest {
                    system_prompt,
                    user_prompt: prompt_clone,
                    model: model_clone,
                    max_tokens: Some(4096),
                    temperature,
                };

                let (tx, rx) = std::sync::mpsc::channel();

                let _ = app_handle.emit("agent-stream", StreamEvent {
                    session_id: sid.clone(),
                    agent_id: aid.clone(),
                    event_type: "working".into(),
                    text: String::new(),
                    tokens_used: None,
                    cost_usd: None,
                });

                match registry
                    .execute_with_fallback(&provider_name, llm_request, tx)
                    .await
                {
                    Ok(response) => {
                        while let Ok(chunk) = rx.try_recv() {
                            if cancel.load(Ordering::Relaxed) {
                                let _ = app_handle.emit("agent-stream", StreamEvent {
                                    session_id: sid.clone(),
                                    agent_id: aid.clone(),
                                    event_type: "cancelled".into(),
                                    text: String::new(),
                                    tokens_used: None,
                                    cost_usd: None,
                                });
                                return;
                            }
                            if !chunk.done && !chunk.text.is_empty() {
                                let _ = app_handle.emit("agent-stream", StreamEvent {
                                    session_id: sid.clone(),
                                    agent_id: aid.clone(),
                                    event_type: "chunk".into(),
                                    text: chunk.text,
                                    tokens_used: None,
                                    cost_usd: None,
                                });
                            }
                        }
                        if !cancel.load(Ordering::Relaxed) {
                            let _ = app_handle.emit("agent-stream", StreamEvent {
                                session_id: sid,
                                agent_id: aid,
                                event_type: "done".into(),
                                text: response.text,
                                tokens_used: Some(response.input_tokens + response.output_tokens),
                                cost_usd: Some(response.cost_usd),
                            });
                        }
                    }
                    Err(e) => {
                        error!(agent_id = %aid, error = %e, "Agent execution failed");
                        let _ = app_handle.emit("agent-stream", StreamEvent {
                            session_id: sid,
                            agent_id: aid,
                            event_type: "error".into(),
                            text: format!("Error: {}", e),
                            tokens_used: None,
                            cost_usd: None,
                        });
                    }
                }
            })
        })
        .collect();

    for handle in handles {
        match handle.await {
            Ok(()) => {}
            Err(e) => error!("Agent task panicked: {}", e),
        }
    }

    // Clean up cancellation token
    {
        if let Ok(mut sessions) = state.active_sessions.write() {
            sessions.remove(&session_id);
        }
    }

    Ok(session_id)
}

#[tauri::command]
fn set_api_keys(
    state: State<AppState>,
    anthropic_key: Option<String>,
    openai_key: Option<String>,
) -> Result<(), AppError> {
    if let Some(key) = anthropic_key {
        if !key.is_empty() {
            state.registry.set_api_key("anthropic", key);
        }
    }
    if let Some(key) = openai_key {
        if !key.is_empty() {
            state.registry.set_api_key("openai", key);
        }
    }
    Ok(())
}

#[tauri::command]
async fn analyze_prompt(
    state: State<'_, AppState>,
    prompt: String,
    provider: String,
) -> Result<SuggestedAgents, AppError> {
    // Build compact agent catalog
    let catalog: String = {
        let orch = &state.orchestrator;
        orch.all_agents()
            .iter()
            .map(|a| format!(
                "{}|{}|{}|{}",
                a.id,
                a.name,
                a.division,
                a.description.chars().take(80).collect::<String>()
            ))
            .collect::<Vec<_>>()
            .join("\n")
    };

    let system_prompt = format!(
        r#"You are the Head Agent — an intelligent task router. Given a user prompt, select the 3-8 most relevant agents from the catalog below.

CATALOG FORMAT: id|name|division|description
---
{}
---

RULES:
- Pick 3-8 agents that together cover the task well
- Mix roles: include a dev, a reviewer, a domain expert as needed
- Prefer agents whose description matches the prompt's domain
- Return ONLY valid JSON: {{"agent_ids":["id1","id2",...],"reasoning":"why these agents"}}

User prompt: {}"#,
        catalog, prompt
    );

    let llm_request = LLMRequest {
        system_prompt,
        user_prompt: prompt.clone(),
        model: None,
        max_tokens: Some(512),
        temperature: Some(0.3),
    };

    let (tx, _rx) = std::sync::mpsc::channel();
    let response = state
        .registry
        .execute_with_fallback(&provider, llm_request, tx)
        .await?;

    let text = response.text.trim();
    let json_str = if let Some(start) = text.find('{') {
        if let Some(end) = text.rfind('}') {
            &text[start..=end]
        } else {
            text
        }
    } else {
        text
    };

    let result: SuggestedAgents = serde_json::from_str(json_str).map_err(|e| {
        AppError::AgentSuggestionParse {
            message: e.to_string(),
            raw: text.to_string(),
        }
    })?;

    let valid: Vec<String> = {
        let orch = &state.orchestrator;
        result
            .agent_ids
            .into_iter()
            .filter(|id| orch.get_agent(id).is_some())
            .collect()
    };

    Ok(SuggestedAgents {
        agent_ids: valid,
        reasoning: result.reasoning,
    })
}

#[tauri::command]
fn get_agent_detail(state: State<AppState>, agent_id: String) -> Result<AgentDetailInfo, AppError> {
    let orch = &state.orchestrator;
    let a = orch.get_agent(&agent_id).ok_or_else(|| AppError::AgentNotFound {
        id: agent_id,
    })?;
    Ok(AgentDetailInfo {
        id: a.id.clone(),
        name: a.name.clone(),
        division: a.division.clone(),
        description: a.description.clone(),
        office_role: a.office_role.clone(),
        emoji: a.emoji.clone(),
        system_prompt: a.system_prompt.clone(),
    })
}

#[tauri::command]
async fn execute_pipeline(
    state: State<'_, AppState>,
    agent_ids: Vec<String>,
    prompt: String,
    provider: String,
    app: tauri::AppHandle,
) -> Result<String, AppError> {
    let session_id = uuid::Uuid::new_v4().to_string();
    info!(session_id = %session_id, agents = ?agent_ids, "Executing pipeline");

    let mut context = prompt.clone();

    for agent_id in &agent_ids {
        let agent = state.orchestrator.get_agent(agent_id).ok_or_else(|| {
            AppError::AgentNotFound {
                id: agent_id.clone(),
            }
        })?;
        let system_prompt = agent.system_prompt.clone();
        let agent_name = agent.name.clone();

        let _ = app.emit("agent-stream", StreamEvent {
            session_id: session_id.clone(),
            agent_id: agent_id.clone(),
            event_type: "working".into(),
            text: String::new(),
            tokens_used: None,
            cost_usd: None,
        });

        let llm_request = LLMRequest {
            system_prompt,
            user_prompt: context.clone(),
            model: None,
            max_tokens: Some(4096),
            temperature: Some(0.7),
        };

        let (tx, _rx) = std::sync::mpsc::channel();
        match state
            .registry
            .execute_with_fallback(&provider, llm_request, tx)
            .await
        {
            Ok(response) => {
                context = response.text.clone();
                let _ = app.emit("agent-stream", StreamEvent {
                    session_id: session_id.clone(),
                    agent_id: agent_id.clone(),
                    event_type: "done".into(),
                    text: response.text,
                    tokens_used: Some(response.input_tokens + response.output_tokens),
                    cost_usd: Some(response.cost_usd),
                });
            }
            Err(e) => {
                error!(
                    agent_id = %agent_id,
                    agent_name = %agent_name,
                    error = %e,
                    "Pipeline agent failed"
                );
                let _ = app.emit("agent-stream", StreamEvent {
                    session_id: session_id.clone(),
                    agent_id: agent_id.clone(),
                    event_type: "error".into(),
                    text: format!("Error: {}", e),
                    tokens_used: None,
                    cost_usd: None,
                });
                return Err(AppError::PipelineFailed {
                    agent_name,
                    agent_id: agent_id.clone(),
                    reason: e.to_string(),
                });
            }
        }
    }

    Ok(session_id)
}

#[tauri::command]
fn get_provider_health(state: State<AppState>) -> Vec<serde_json::Value> {
    state
        .registry
        .list_providers()
        .iter()
        .map(|name| {
            serde_json::json!({
                "name": name,
                "has_key": state.registry.has_api_key(name),
            })
        })
        .collect()
}

#[tauri::command]
fn cancel_session(state: State<AppState>, session_id: String) -> bool {
    let sessions = match state.active_sessions.read() {
        Ok(s) => s,
        Err(_) => return false,
    };
    if let Some(token) = sessions.get(&session_id) {
        token.store(true, Ordering::Relaxed);
        info!(session_id = %session_id, "Session cancelled");
        true
    } else {
        false
    }
}

#[derive(Debug, Serialize, Deserialize)]
struct QualityVerdict {
    passed: bool,
    score: f32,
    reasoning: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct TaskSubtask {
    title: String,
    description: String,
    suggested_agent_role: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct DecomposedTask {
    subtasks: Vec<TaskSubtask>,
    reasoning: String,
}

#[tauri::command]
async fn evaluate_quality(
    state: State<'_, AppState>,
    response: String,
    criteria: String,
    provider: String,
) -> Result<QualityVerdict, AppError> {
    let system_prompt = format!(
        r#"You are a quality evaluator. Rate the following response against the criteria.

CRITERIA: {}

RESPONSE:
{}

Return ONLY valid JSON: {{"passed":true/false,"score":0.0-1.0,"reasoning":"brief explanation"}}"#,
        criteria, response
    );

    let llm_request = LLMRequest {
        system_prompt,
        user_prompt: response,
        model: None,
        max_tokens: Some(256),
        temperature: Some(0.1),
    };

    let (tx, _rx) = std::sync::mpsc::channel();
    let llm_response = state
        .registry
        .execute_with_fallback(&provider, llm_request, tx)
        .await?;

    let text = llm_response.text.trim();
    let json_str = if let Some(start) = text.find('{') {
        if let Some(end) = text.rfind('}') {
            &text[start..=end]
        } else {
            text
        }
    } else {
        text
    };

    serde_json::from_str(json_str).map_err(|e| AppError::AgentSuggestionParse {
        message: e.to_string(),
        raw: text.to_string(),
    })
}

#[tauri::command]
async fn decompose_task(
    state: State<'_, AppState>,
    prompt: String,
    provider: String,
) -> Result<DecomposedTask, AppError> {
    let system_prompt = r#"You are a task decomposition expert. Break complex tasks into 2-5 independent subtasks.

Each subtask should be:
- Atomic (can be worked on independently)
- Clear (has a specific deliverable)
- Assigned to a role that fits (dev, qa, arch, pm, ops, res, gate, designer)

Return ONLY valid JSON:
{"subtasks":[{"title":"short title","description":"what to do","suggested_agent_role":"dev"}],"reasoning":"why this breakdown"}"#;

    let llm_request = LLMRequest {
        system_prompt: system_prompt.into(),
        user_prompt: prompt,
        model: None,
        max_tokens: Some(1024),
        temperature: Some(0.3),
    };

    let (tx, _rx) = std::sync::mpsc::channel();
    let response = state
        .registry
        .execute_with_fallback(&provider, llm_request, tx)
        .await?;

    let text = response.text.trim();
    let json_str = if let Some(start) = text.find('{') {
        if let Some(end) = text.rfind('}') {
            &text[start..=end]
        } else {
            text
        }
    } else {
        text
    };

    serde_json::from_str(json_str).map_err(|e| AppError::AgentSuggestionParse {
        message: e.to_string(),
        raw: text.to_string(),
    })
}

#[tauri::command]
async fn replay_session(
    state: State<'_, AppState>,
    prompt: String,
    agent_ids: Vec<String>,
    provider: String,
    app: tauri::AppHandle,
) -> Result<String, AppError> {
    execute_task(
        state,
        TaskRequest {
            agent_ids,
            prompt,
            provider,
            model: None,
            temperature: Some(0.7),
        },
        app,
    )
    .await
}

#[tauri::command]
fn commit_batch(message: String) -> Result<String, String> {
    let output = StdCommand::new("git")
        .args(["add", "-A"])
        .output()
        .map_err(|e| format!("git add failed: {}", e))?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }

    let output = StdCommand::new("git")
        .args(["diff", "--cached", "--quiet"])
        .output()
        .map_err(|e| format!("git diff failed: {}", e))?;
    if output.status.success() {
        return Ok("nothing to commit".into());
    }

    let output = StdCommand::new("git")
        .args(["commit", "-m", &message])
        .output()
        .map_err(|e| format!("git commit failed: {}", e))?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }

    let hash = StdCommand::new("git")
        .args(["rev-parse", "--short", "HEAD"])
        .output()
        .map_err(|e| format!("git rev-parse failed: {}", e))?;

    Ok(String::from_utf8_lossy(&hash.stdout).trim().to_string())
}

#[tauri::command]
fn rollback_batch() -> Result<(), String> {
    let output = StdCommand::new("git")
        .args(["reset", "--hard", "HEAD"])
        .output()
        .map_err(|e| format!("git reset failed: {}", e))?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }
    Ok(())
}

#[tauri::command]
fn get_git_branch() -> Result<String, String> {
    let output = StdCommand::new("git")
        .args(["branch", "--show-current"])
        .output()
        .map_err(|e| format!("git branch failed: {}", e))?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }
    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

#[tauri::command]
fn create_branch(name: String) -> Result<(), String> {
    let output = StdCommand::new("git")
        .args(["checkout", "-b", &name])
        .output()
        .map_err(|e| format!("git checkout failed: {}", e))?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }
    Ok(())
}

#[tauri::command]
fn start_sleep_prevent() -> Result<u32, String> {
    #[cfg(target_os = "macos")]
    {
        let child = StdCommand::new("caffeinate")
            .args(["-d", "-i", "-s"])
            .spawn()
            .map_err(|e| format!("caffeinate failed: {}", e))?;
        Ok(child.id())
    }
    #[cfg(not(target_os = "macos"))]
    {
        let _ = warn!("Sleep prevention only implemented on macOS");
        Ok(0)
    }
}

#[tauri::command]
fn stop_sleep_prevent(pid: u32) -> Result<(), String> {
    #[cfg(target_os = "macos")]
    {
        let _ = StdCommand::new("kill")
            .arg(pid.to_string())
            .output();
        Ok(())
    }
    #[cfg(not(target_os = "macos"))]
    {
        let _ = pid;
        Ok(())
    }
}

fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    let agents_json = include_str!("../../public/agents.json");
    let registry = AgentRegistry::load(agents_json).expect("Failed to load agents registry");
    let orchestrator = Orchestrator::new(registry);
    let provider_registry = Arc::new(ProviderRegistry::new());

    info!("Agent Office starting up");

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .manage(AppState {
            orchestrator,
            registry: provider_registry,
            active_sessions: RwLock::new(HashMap::new()),
        })
        .invoke_handler(tauri::generate_handler![
            get_agents,
            search_agents,
            execute_task,
            set_api_keys,
            analyze_prompt,
            get_agent_detail,
            execute_pipeline,
            get_provider_health,
            cancel_session,
            evaluate_quality,
            commit_batch,
            rollback_batch,
            get_git_branch,
            create_branch,
            start_sleep_prevent,
            stop_sleep_prevent,
            decompose_task,
            replay_session,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
