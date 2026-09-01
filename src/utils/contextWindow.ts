const CHARS_PER_TOKEN = 4;

export interface ContextBudget {
  maxTokens: number;
  usedTokens: number;
  remaining: number;
}

export function estimateTokens(text: string): number {
  return Math.ceil(text.length / CHARS_PER_TOKEN);
}

export function truncateToBudget(text: string, maxTokens: number): { text: string; truncated: boolean } {
  const tokens = estimateTokens(text);
  if (tokens <= maxTokens) return { text, truncated: false };
  const maxChars = maxTokens * CHARS_PER_TOKEN;
  return { text: text.slice(0, maxChars) + '\n\n[...truncated to fit context window]', truncated: true };
}

export function buildContextBudget(
  modelContextWindow: number,
  systemPromptTokens: number,
  overheadTokens: number = 500,
): ContextBudget {
  const maxTokens = modelContextWindow - systemPromptTokens - overheadTokens;
  return { maxTokens: Math.max(maxTokens, 0), usedTokens: 0, remaining: maxTokens };
}

export function allocateBudget(
  budget: ContextBudget,
  sections: { label: string; tokens: number }[],
): { label: string; maxTokens: number }[] {
  const totalNeeded = sections.reduce((sum, s) => sum + s.tokens, 0);
  if (totalNeeded <= budget.remaining) {
    return sections.map(s => ({ label: s.label, maxTokens: s.tokens }));
  }
  const ratio = budget.remaining / totalNeeded;
  return sections.map(s => ({ label: s.label, maxTokens: Math.floor(s.tokens * ratio) }));
}

export const MODEL_CONTEXT_WINDOWS: Record<string, number> = {
  'claude-3-5-sonnet-20241022': 200_000,
  'claude-3-5-haiku-20241022': 200_000,
  'claude-3-opus-20240229': 200_000,
  'gpt-4o': 128_000,
  'gpt-4o-mini': 128_000,
  'o1': 200_000,
  'o1-mini': 128_000,
  'o3-mini': 200_000,
};
