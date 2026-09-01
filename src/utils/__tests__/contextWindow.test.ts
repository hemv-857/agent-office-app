import { describe, it, expect } from 'vitest';
import { estimateTokens, truncateToBudget, buildContextBudget, MODEL_CONTEXT_WINDOWS } from '../contextWindow';

describe('contextWindow', () => {
  it('estimates tokens correctly', () => {
    expect(estimateTokens('hello')).toBe(2); // 5 chars / 4 = 1.25 → ceil = 2
    expect(estimateTokens('')).toBe(0);
    expect(estimateTokens('a'.repeat(100))).toBe(25);
  });

  it('truncates when over budget', () => {
    const longText = 'a'.repeat(1000);
    const result = truncateToBudget(longText, 100); // 100 tokens = 400 chars
    expect(result.truncated).toBe(true);
    expect(result.text.length).toBeLessThan(1000);
    expect(result.text).toContain('[...truncated');
  });

  it('does not truncate when under budget', () => {
    const shortText = 'hello world';
    const result = truncateToBudget(shortText, 100);
    expect(result.truncated).toBe(false);
    expect(result.text).toBe('hello world');
  });

  it('builds context budget', () => {
    const budget = buildContextBudget(200_000, 5000, 500);
    expect(budget.maxTokens).toBe(194_500);
    expect(budget.usedTokens).toBe(0);
    expect(budget.remaining).toBe(194_500);
  });

  it('has model context windows', () => {
    expect(MODEL_CONTEXT_WINDOWS['claude-3-5-sonnet-20241022']).toBe(200_000);
    expect(MODEL_CONTEXT_WINDOWS['gpt-4o']).toBe(128_000);
  });
});
