import type { AgentResult, Agent, OfficeAgent } from '../types';
import { sanitizeFilename, redactSecrets } from './sanitize';

function triggerDownload(content: string, filename: string, mimeType: string): void {
  const blob = new Blob([content], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

function agentFileName(agentName: string): string {
  return sanitizeFilename(agentName.replace(/\s+/g, '-').toLowerCase());
}

export function exportResultAsMarkdown(result: AgentResult, agent: Agent | undefined): void {
  const md = [
    `# ${agent?.emoji || ''} ${result.agent_name}`,
    '',
    `Status: ${result.status}`,
    `Tokens: ${result.tokens_used}`,
    `Cost: $${result.cost_usd.toFixed(4)}`,
    `Time: ${result.elapsed_ms ? (result.elapsed_ms / 1000).toFixed(1) + 's' : 'N/A'}`,
    '',
    '---',
    '',
    redactSecrets(result.response),
    '',
  ].join('\n');
  triggerDownload(md, `${agentFileName(result.agent_name)}-result.md`, 'text/markdown');
}

export function exportResultsAsMarkdown(results: AgentResult[], agents: Agent[]): void {
  const data = results.map(r => {
    const agent = agents.find(a => a.id === r.agent_id);
    return {
      agent: r.agent_name,
      emoji: agent?.emoji,
      role: agent?.office_role,
      status: r.status,
      response: r.response,
      tokens: r.tokens_used,
      cost: r.cost_usd,
    };
  });
  const md = data.map(r =>
    `## ${r.emoji || ''} ${r.agent} (${r.role})\n\nStatus: ${r.status} | Tokens: ${r.tokens} | Cost: $${r.cost.toFixed(4)}\n\n${redactSecrets(r.response)}\n`
  ).join('\n---\n\n');
  triggerDownload(md, `agent-results-${Date.now()}.md`, 'text/markdown');
}

export function exportResultsAsJson(results: AgentResult[], agents: Agent[]): void {
  const data = results.map(r => {
    const agent = agents.find(a => a.id === r.agent_id);
    return {
      agent: r.agent_name,
      emoji: agent?.emoji,
      role: agent?.office_role,
      status: r.status,
      response: r.response,
      tokens: r.tokens_used,
      cost: r.cost_usd,
      time_ms: r.elapsed_ms,
    };
  });
  triggerDownload(JSON.stringify(data, null, 2), `agent-results-${Date.now()}.json`, 'application/json');
}

export function exportLayout(
  officeAgents: OfficeAgent[],
  favorites: Set<string>,
  costBudget: number,
  provider: string,
  customAgents: unknown[],
): void {
  const data = {
    officeAgents,
    favorites: [...favorites],
    costBudget,
    provider,
    customAgents,
  };
  triggerDownload(JSON.stringify(data, null, 2), `agent-office-layout-${Date.now()}.json`, 'application/json');
}
