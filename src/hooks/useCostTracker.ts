import { useState, useCallback } from 'react';
import { loadJson, saveJson } from '../utils/storage';

const STORAGE_KEY = 'agent-office-cost-history';

export interface CostEntry {
  id: string;
  timestamp: string;
  prompt: string;
  agentIds: string[];
  provider: string;
  totalCost: number;
  totalTokens: number;
  sessionDurationMs: number;
}

interface BudgetConfig {
  dailyLimit: number;
  perSessionLimit: number;
  alertThreshold: number; // percentage (0-1) of daily limit that triggers warning
}

const DEFAULT_BUDGET: BudgetConfig = { dailyLimit: 0, perSessionLimit: 0, alertThreshold: 0.8 };

export function useCostTracker() {
  const [entries, setEntries] = useState<CostEntry[]>(() =>
    loadJson<CostEntry[]>(STORAGE_KEY, [])
  );
  const [budget, setBudgetState] = useState<BudgetConfig>(() =>
    loadJson<BudgetConfig>('agent-office-budget-config', DEFAULT_BUDGET)
  );

  const setBudget = useCallback((config: Partial<BudgetConfig>) => {
    setBudgetState(prev => {
      const next = { ...prev, ...config };
      saveJson('agent-office-budget-config', next);
      return next;
    });
  }, []);

  const recordSession = useCallback((
    prompt: string,
    agentIds: string[],
    provider: string,
    totalCost: number,
    totalTokens: number,
    sessionDurationMs: number,
  ) => {
    const entry: CostEntry = {
      id: crypto.randomUUID(),
      timestamp: new Date().toISOString(),
      prompt: prompt.slice(0, 200),
      agentIds,
      provider,
      totalCost,
      totalTokens,
      sessionDurationMs,
    };
    setEntries(prev => {
      const next = [entry, ...prev].slice(0, 200);
      saveJson(STORAGE_KEY, next);
      return next;
    });
    return entry;
  }, []);

  const getTodayCost = useCallback((): number => {
    const today = new Date().toISOString().slice(0, 10);
    return entries
      .filter(e => e.timestamp.startsWith(today))
      .reduce((sum, e) => sum + e.totalCost, 0);
  }, [entries]);

  const getTotalCost = useCallback((): number => {
    return entries.reduce((sum, e) => sum + e.totalCost, 0);
  }, [entries]);

  const checkBudget = useCallback((): { ok: boolean; warning: boolean; message: string } => {
    if (budget.dailyLimit <= 0) return { ok: true, warning: false, message: '' };
    const todayCost = getTodayCost();
    const ratio = todayCost / budget.dailyLimit;
    if (ratio >= 1) {
      return { ok: false, warning: true, message: `Daily budget exceeded: $${todayCost.toFixed(4)} / $${budget.dailyLimit.toFixed(2)}` };
    }
    if (ratio >= budget.alertThreshold) {
      return { ok: true, warning: true, message: `Daily budget warning: $${todayCost.toFixed(4)} / $${budget.dailyLimit.toFixed(2)} (${(ratio * 100).toFixed(0)}%)` };
    }
    return { ok: true, warning: false, message: '' };
  }, [budget, getTodayCost]);

  const getWeeklyCost = useCallback((): number => {
    const now = new Date();
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    return entries
      .filter(e => new Date(e.timestamp) >= weekAgo)
      .reduce((sum, e) => sum + e.totalCost, 0);
  }, [entries]);

  const getCostByProvider = useCallback((): Record<string, number> => {
    const byProvider: Record<string, number> = {};
    for (const e of entries) {
      byProvider[e.provider] = (byProvider[e.provider] || 0) + e.totalCost;
    }
    return byProvider;
  }, [entries]);

  const getCostByAgent = useCallback((): Record<string, number> => {
    const byAgent: Record<string, number> = {};
    for (const e of entries) {
      for (const id of e.agentIds) {
        byAgent[id] = (byAgent[id] || 0) + e.totalCost / e.agentIds.length;
      }
    }
    return byAgent;
  }, [entries]);

  return {
    entries,
    budget,
    setBudget,
    recordSession,
    getTodayCost,
    getTotalCost,
    getWeeklyCost,
    getCostByProvider,
    getCostByAgent,
    checkBudget,
  };
}
