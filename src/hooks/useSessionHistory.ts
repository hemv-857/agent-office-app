import { useState, useCallback } from 'react';
import { invoke } from '@tauri-apps/api/core';
import type { AgentResult } from '../types';
import { loadJson, saveJson } from '../utils/storage';

const STORAGE_KEY = 'agent-office-sessions';

interface Session {
  id: string;
  prompt: string;
  agentIds: string[];
  provider: string;
  timestamp: string;
  results: AgentResult[];
  totalCost: number;
  totalTokens: number;
}

export function useSessionHistory() {
  const [sessions, setSessions] = useState<Session[]>(() =>
    loadJson<Session[]>(STORAGE_KEY, [])
  );

  const saveSession = useCallback(
    (
      prompt: string,
      agentIds: string[],
      provider: string,
      results: AgentResult[],
      totalCost: number,
      totalTokens: number,
    ) => {
      const session: Session = {
        id: crypto.randomUUID(),
        prompt,
        agentIds,
        provider,
        timestamp: new Date().toISOString(),
        results,
        totalCost,
        totalTokens,
      };
      setSessions((prev) => {
        const next = [session, ...prev].slice(0, 100); // Keep last 100 sessions
        saveJson(STORAGE_KEY, next);
        return next;
      });
      return session;
    },
    [],
  );

  const deleteSession = useCallback((id: string) => {
    setSessions((prev) => {
      const next = prev.filter((s) => s.id !== id);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const clearSessions = useCallback(() => {
    saveJson(STORAGE_KEY, []);
    setSessions([]);
  }, []);

  const searchSessions = useCallback(
    (query: string) => {
      if (!query.trim()) return sessions;
      const lower = query.toLowerCase();
      return sessions.filter(
        (s) =>
          s.prompt.toLowerCase().includes(lower) ||
          s.agentIds.some((id) => id.toLowerCase().includes(lower)),
      );
    },
    [sessions],
  );

  const replaySession = useCallback(async (session: Session, provider: string) => {
    await invoke('replay_session', {
      prompt: session.prompt,
      agentIds: session.agentIds,
      provider,
    });
  }, []);

  return {
    sessions,
    saveSession,
    deleteSession,
    clearSessions,
    searchSessions,
    replaySession,
  };
}
