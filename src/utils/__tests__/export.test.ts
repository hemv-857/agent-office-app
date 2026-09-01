import { describe, it, expect } from 'vitest';
import type { Agent } from '../../types';

// Inline the export functions to test them without Tauri deps
function exportResultAsMarkdown(
  result: { agent_name: string; agent_id: string; status: string; tokens_used: number; cost_usd: number; elapsed_ms?: number; response: string },
  agent?: Agent,
): string {
  const lines = [
    `# ${result.agent_name}`,
    '',
    `- **Status:** ${result.status}`,
    `- **Tokens:** ${result.tokens_used}`,
    `- **Cost:** $${result.cost_usd.toFixed(4)}`,
  ];
  if (result.elapsed_ms) {
    lines.push(`- **Time:** ${(result.elapsed_ms / 1000).toFixed(1)}s`);
  }
  if (agent?.description) {
    lines.push(`- **Role:** ${agent.description}`);
  }
  lines.push('', '---', '', result.response);
  return lines.join('\n');
}

function exportResultsAsMarkdown(
  results: Array<{ agent_name: string; agent_id: string; status: string; tokens_used: number; cost_usd: number; response: string }>,
): string {
  const totalCost = results.reduce((sum, r) => sum + r.cost_usd, 0);
  const totalTokens = results.reduce((sum, r) => sum + r.tokens_used, 0);
  const lines = [
    '# Agent Office Results',
    '',
    `**Total Cost:** $${totalCost.toFixed(4)} | **Total Tokens:** ${totalTokens}`,
    '',
    '---',
    '',
  ];
  for (const r of results) {
    lines.push(`## ${r.agent_name}`, '', r.response, '', '---', '');
  }
  return lines.join('\n');
}

describe('export utils', () => {
  const mockResult = {
    agent_name: 'Test Agent',
    agent_id: 'test-agent',
    status: 'completed',
    tokens_used: 150,
    cost_usd: 0.0023,
    response: 'Hello world response',
  };

  it('exportResultAsMarkdown includes key fields', () => {
    const md = exportResultAsMarkdown(mockResult);
    expect(md).toContain('# Test Agent');
    expect(md).toContain('completed');
    expect(md).toContain('150');
    expect(md).toContain('0.0023');
    expect(md).toContain('Hello world response');
  });

  it('exportResultAsMarkdown includes agent description when provided', () => {
    const agent = { description: 'Senior developer' } as Agent;
    const md = exportResultAsMarkdown(mockResult, agent);
    expect(md).toContain('Senior developer');
  });

  it('exportResultsAsMarkdown includes total cost', () => {
    const results = [
      { ...mockResult },
      { ...mockResult, agent_name: 'Agent 2', cost_usd: 0.001, tokens_used: 100 },
    ];
    const md = exportResultsAsMarkdown(results);
    expect(md).toContain('Agent Office Results');
    expect(md).toContain('0.0033'); // total cost
    expect(md).toContain('250'); // total tokens
  });
});
