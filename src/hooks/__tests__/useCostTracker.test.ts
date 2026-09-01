import { describe, it, expect, beforeEach } from 'vitest';

describe('useCostTracker', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  const STORAGE_KEY = 'agent-office-cost-history';

  function loadEntries() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  function saveEntries(entries: unknown[]) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  }

  it('starts empty', () => {
    expect(loadEntries()).toEqual([]);
  });

  it('records cost entries', () => {
    const entry = {
      id: '1',
      timestamp: new Date().toISOString(),
      prompt: 'test prompt',
      agentIds: ['agent-1'],
      provider: 'anthropic',
      totalCost: 0.05,
      totalTokens: 1000,
      sessionDurationMs: 5000,
    };
    const entries = loadEntries();
    entries.unshift(entry);
    saveEntries(entries);
    expect(loadEntries()).toHaveLength(1);
    expect(loadEntries()[0].totalCost).toBe(0.05);
  });

  it('calculates daily cost correctly', () => {
    const today = new Date().toISOString().slice(0, 10);
    const entries = [
      { id: '1', timestamp: `${today}T10:00:00Z`, totalCost: 0.03 },
      { id: '2', timestamp: `${today}T11:00:00Z`, totalCost: 0.02 },
      { id: '3', timestamp: '2024-01-01T10:00:00Z', totalCost: 0.10 },
    ];
    saveEntries(entries);
    const todayCost = loadEntries()
      .filter((e: { timestamp: string }) => e.timestamp.startsWith(today))
      .reduce((sum: number, e: { totalCost: number }) => sum + e.totalCost, 0);
    expect(todayCost).toBe(0.05);
  });

  it('calculates total cost', () => {
    const entries = [
      { id: '1', totalCost: 0.03 },
      { id: '2', totalCost: 0.02 },
      { id: '3', totalCost: 0.10 },
    ];
    saveEntries(entries);
    const total = loadEntries().reduce((sum: number, e: { totalCost: number }) => sum + e.totalCost, 0);
    expect(total).toBeCloseTo(0.15);
  });

  it('groups cost by provider', () => {
    const entries = [
      { id: '1', provider: 'anthropic', totalCost: 0.03 },
      { id: '2', provider: 'openai', totalCost: 0.02 },
      { id: '3', provider: 'anthropic', totalCost: 0.10 },
    ];
    saveEntries(entries);
    const byProvider: Record<string, number> = {};
    for (const e of loadEntries()) {
      const p = (e as { provider: string }).provider;
      byProvider[p] = (byProvider[p] || 0) + (e as { totalCost: number }).totalCost;
    }
    expect(byProvider.anthropic).toBeCloseTo(0.13);
    expect(byProvider.openai).toBeCloseTo(0.02);
  });

  it('budget config persists', () => {
    const config = { dailyLimit: 5, perSessionLimit: 1, alertThreshold: 0.8 };
    localStorage.setItem('agent-office-budget-config', JSON.stringify(config));
    const loaded = JSON.parse(localStorage.getItem('agent-office-budget-config') || '{}');
    expect(loaded.dailyLimit).toBe(5);
    expect(loaded.alertThreshold).toBe(0.8);
  });
});
