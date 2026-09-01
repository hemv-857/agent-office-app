export interface Agent {
  id: string;
  name: string;
  division: string;
  description: string;
  office_role: string;
  emoji: string;
  system_prompt?: string;
}

export interface AgentWithPrompt extends Agent {
  system_prompt: string;
}

export interface AgentResult {
  agent_id: string;
  agent_name: string;
  response: string;
  tokens_used: number;
  cost_usd: number;
  status: string;
  elapsed_ms?: number;
}

export interface StreamEvent {
  session_id: string;
  agent_id: string;
  event_type: string;
  text: string;
  tokens_used: number | null;
  cost_usd: number | null;
}

export type OfficeAgentStatus = 'idle' | 'working' | 'blocked' | 'done';

export interface OfficeAgent {
  id: string;
  name: string;
  role: string;
  status: OfficeAgentStatus;
  emoji: string;
  message?: string;
}

export interface Suggestion {
  agentIds: string[];
  reasoning: string;
}

export interface AgentGroup {
  name: string;
  agentIds: string[];
}

export interface OfficePreset {
  name: string;
  agents: { id: string; name: string; role: string; emoji: string }[];
}

export interface ActivityEntry {
  id: string;
  timestamp: string;
  message: string;
  type: 'info' | 'success' | 'error' | 'warning';
}

export interface ChatMessage {
  role: 'user' | 'agent';
  text: string;
}

export interface AgentDetail {
  id: string;
  name: string;
  division: string;
  description: string;
  office_role: string;
  emoji: string;
  system_prompt: string;
}

export interface CustomAgentForm {
  name: string;
  division: string;
  description: string;
  office_role: string;
  emoji: string;
  system_prompt: string;
}

export type Theme = 'dark' | 'light';

export type RatingDirection = 'up' | 'down';

export interface SidebarSections {
  groups: boolean;
  presets: boolean;
  agents: boolean;
}

export interface AgentStats {
  id: string;
  name: string;
  emoji: string;
  runs: number;
  totalTime: number;
  totalCost: number;
  successes: number;
  failures: number;
  avgTime: number;
  successRate: number;
}

export interface Subtask {
  title: string;
  description: string;
  suggested_agent_role: string;
}

export interface DecomposedTask {
  subtasks: Subtask[];
  reasoning: string;
}
