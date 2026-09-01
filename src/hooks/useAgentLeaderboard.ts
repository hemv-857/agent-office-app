import { useState, useCallback } from 'react';
import { loadJson, saveJson } from '../utils/storage';

const STORAGE_KEY = 'agent-office-leaderboard';

export interface AgentLeaderboardEntry {
  agentId: string;
  name: string;
  emoji: string;
  runs: number;
  successes: number;
  failures: number;
  totalTokens: number;
  totalCost: number;
  totalTimeMs: number;
  avgTimeMs: number;
  successRate: number;
  avgCostPerRun: number;
  lastRun: string;
}

export function useAgentLeaderboard() {
  const [entries, setEntries] = useState<AgentLeaderboardEntry[]>(() =>
    loadJson<AgentLeaderboardEntry[]>(STORAGE_KEY, [])
  );

  const recordRun = useCallback((
    agentId: string,
    name: string,
    emoji: string,
    success: boolean,
    tokens: number,
    cost: number,
    timeMs: number,
  ) => {
    setEntries(prev => {
      const existing = prev.find(e => e.agentId === agentId);
      let next: AgentLeaderboardEntry[];
      if (existing) {
        const runs = existing.runs + 1;
        const successes = existing.successes + (success ? 1 : 0);
        next = prev.map(e => e.agentId === agentId ? {
          ...e,
          runs,
          successes,
          failures: e.failures + (success ? 0 : 1),
          totalTokens: e.totalTokens + tokens,
          totalCost: e.totalCost + cost,
          totalTimeMs: e.totalTimeMs + timeMs,
          avgTimeMs: (e.totalTimeMs + timeMs) / runs,
          successRate: (successes / runs) * 100,
          avgCostPerRun: (e.totalCost + cost) / runs,
          lastRun: new Date().toISOString(),
        } : e);
      } else {
        next = [...prev, {
          agentId,
          name,
          emoji,
          runs: 1,
          successes: success ? 1 : 0,
          failures: success ? 0 : 1,
          totalTokens: tokens,
          totalCost: cost,
          totalTimeMs: timeMs,
          avgTimeMs: timeMs,
          successRate: success ? 100 : 0,
          avgCostPerRun: cost,
          lastRun: new Date().toISOString(),
        }];
      }
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const getLeaderboard = useCallback((sortBy: 'runs' | 'successRate' | 'totalCost' | 'avgTimeMs' = 'runs'): AgentLeaderboardEntry[] => {
    return [...entries].sort((a, b) => {
      if (sortBy === 'successRate') return b.successRate - a.successRate;
      if (sortBy === 'totalCost') return a.totalCost - b.totalCost; // lower is better
      if (sortBy === 'avgTimeMs') return a.avgTimeMs - b.avgTimeMs; // faster is better
      return b.runs - a.runs;
    });
  }, [entries]);

  const getTopAgents = useCallback((n: number = 5): AgentLeaderboardEntry[] => {
    return getLeaderboard('runs').slice(0, n);
  }, [getLeaderboard]);

  const getMostEfficient = useCallback((): AgentLeaderboardEntry | null => {
    const withRuns = entries.filter(e => e.runs >= 3);
    if (withRuns.length === 0) return null;
    return withRuns.sort((a, b) => b.successRate - a.successRate || a.avgCostPerRun - b.avgCostPerRun)[0];
  }, [entries]);

  const clearLeaderboard = useCallback(() => {
    saveJson(STORAGE_KEY, []);
    setEntries([]);
  }, []);

  return {
    entries,
    recordRun,
    getLeaderboard,
    getTopAgents,
    getMostEfficient,
    clearLeaderboard,
  };
}
