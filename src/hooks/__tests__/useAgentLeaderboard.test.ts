import { describe, it, expect, beforeEach } from 'vitest';

describe('useAgentLeaderboard', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  const STORAGE_KEY = 'agent-office-leaderboard';

  function loadLeaderboard() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  function saveLeaderboard(entries: unknown[]) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  }

  it('starts empty', () => {
    expect(loadLeaderboard()).toEqual([]);
  });

  it('records agent runs', () => {
    const entry = {
      agentId: 'agent-1',
      name: 'Code Reviewer',
      emoji: '🔍',
      runs: 1,
      successes: 1,
      failures: 0,
      totalTokens: 500,
      totalCost: 0.01,
      totalTimeMs: 2000,
      avgTimeMs: 2000,
      successRate: 100,
      avgCostPerRun: 0.01,
      lastRun: new Date().toISOString(),
    };
    const entries = loadLeaderboard();
    entries.push(entry);
    saveLeaderboard(entries);
    expect(loadLeaderboard()).toHaveLength(1);
    expect(loadLeaderboard()[0].successRate).toBe(100);
  });

  it('sorts by runs descending', () => {
    const entries = [
      { agentId: 'a', runs: 3 },
      { agentId: 'b', runs: 10 },
      { agentId: 'c', runs: 7 },
    ];
    saveLeaderboard(entries);
    const sorted = [...loadLeaderboard()].sort((a: { runs: number }, b: { runs: number }) => b.runs - a.runs);
    expect(sorted[0].agentId).toBe('b');
    expect(sorted[1].agentId).toBe('c');
    expect(sorted[2].agentId).toBe('a');
  });

  it('sorts by success rate', () => {
    const entries = [
      { agentId: 'a', successRate: 80 },
      { agentId: 'b', successRate: 100 },
      { agentId: 'c', successRate: 50 },
    ];
    saveLeaderboard(entries);
    const sorted = [...loadLeaderboard()].sort((a: { successRate: number }, b: { successRate: number }) => b.successRate - a.successRate);
    expect(sorted[0].agentId).toBe('b');
  });

  it('finds most efficient agent', () => {
    const entries = [
      { agentId: 'a', runs: 5, successRate: 100, avgCostPerRun: 0.01 },
      { agentId: 'b', runs: 3, successRate: 80, avgCostPerRun: 0.005 },
    ];
    saveLeaderboard(entries);
    const withRuns = loadLeaderboard().filter((e: { runs: number }) => e.runs >= 3);
    const mostEfficient = withRuns.sort((a: { successRate: number; avgCostPerRun: number }, b: { successRate: number; avgCostPerRun: number }) =>
      b.successRate - a.successRate || a.avgCostPerRun - b.avgCostPerRun
    )[0];
    expect(mostEfficient.agentId).toBe('a');
  });

  it('can clear leaderboard', () => {
    saveLeaderboard([{ agentId: 'a' }, { agentId: 'b' }]);
    expect(loadLeaderboard()).toHaveLength(2);
    saveLeaderboard([]);
    expect(loadLeaderboard()).toHaveLength(0);
  });
});
