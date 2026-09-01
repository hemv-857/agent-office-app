import { useState, useEffect, useRef } from 'react';
import { listen } from '@tauri-apps/api/event';
import type { AgentResult, AgentStats, StreamEvent } from '../types';

export function useStreaming() {
  const [streamResults, setStreamResults] = useState<Map<string, AgentResult>>(new Map());
  const [activeSession, setActiveSession] = useState<string | null>(null);
  const [expandedCards, setExpandedCards] = useState<Set<string>>(new Set());
  const [compareMode, setCompareMode] = useState(false);
  const [bookmarks, setBookmarks] = useState<Set<string>>(new Set());
  const [ratings, setRatings] = useState<Map<string, 'up' | 'down'>>(new Map());
  const [selectedResults, setSelectedResults] = useState<Set<string>>(new Set());
  const resultsRef = useRef<HTMLDivElement>(null);
  const agentStartTimes = useRef<Map<string, number>>(new Map());

  useEffect(() => {
    const unlisten = listen<StreamEvent>('agent-stream', (event) => {
      const se = event.payload;
      setStreamResults(prev => {
        const next = new Map(prev);
        const existing = next.get(se.agent_id);
        if (se.event_type === 'working') {
          agentStartTimes.current.set(se.agent_id, Date.now());
          next.set(se.agent_id, {
            agent_id: se.agent_id,
            agent_name: existing?.agent_name || se.agent_id,
            response: '',
            tokens_used: 0,
            cost_usd: 0,
            status: 'working',
          });
        } else if (se.event_type === 'chunk') {
          next.set(se.agent_id, {
            agent_id: se.agent_id,
            agent_name: existing?.agent_name || se.agent_id,
            response: (existing?.response || '') + se.text,
            tokens_used: existing?.tokens_used || 0,
            cost_usd: existing?.cost_usd || 0,
            status: 'working',
          });
        } else if (se.event_type === 'done') {
          const start = agentStartTimes.current.get(se.agent_id) || Date.now();
          const elapsed = Date.now() - start;
          agentStartTimes.current.delete(se.agent_id);
          next.set(se.agent_id, {
            agent_id: se.agent_id,
            agent_name: existing?.agent_name || se.agent_id,
            response: se.text || existing?.response || '',
            tokens_used: se.tokens_used || 0,
            cost_usd: se.cost_usd || 0,
            status: 'completed',
            elapsed_ms: elapsed,
          });
        } else if (se.event_type === 'error') {
          next.set(se.agent_id, {
            agent_id: se.agent_id,
            agent_name: existing?.agent_name || se.agent_id,
            response: se.text,
            tokens_used: 0,
            cost_usd: 0,
            status: 'error',
          });
        }
        return next;
      });
    });
    return () => { unlisten.then(fn => fn()); };
  }, []);

  useEffect(() => {
    if (resultsRef.current) {
      resultsRef.current.scrollTop = resultsRef.current.scrollHeight;
    }
  }, [streamResults]);

  const resultsArray = Array.from(streamResults.values());

  const totalCost = resultsArray.reduce((sum, r) => sum + r.cost_usd, 0);
  const totalTokens = resultsArray.reduce((sum, r) => sum + r.tokens_used, 0);

  function clearResults() {
    setStreamResults(new Map());
    setActiveSession(null);
  }

  function toggleCardExpanded(agentId: string) {
    setExpandedCards(prev => {
      const next = new Set(prev);
      if (next.has(agentId)) next.delete(agentId);
      else next.add(agentId);
      return next;
    });
  }

  function toggleBookmark(agentId: string) {
    setBookmarks(prev => {
      const next = new Set(prev);
      if (next.has(agentId)) next.delete(agentId);
      else next.add(agentId);
      return next;
    });
  }

  function toggleRating(agentId: string, direction: 'up' | 'down') {
    setRatings(prev => {
      const next = new Map(prev);
      if (next.get(agentId) === direction) next.delete(agentId);
      else next.set(agentId, direction);
      return next;
    });
  }

  function toggleResultSelect(agentId: string) {
    setSelectedResults(prev => {
      const next = new Set(prev);
      if (next.has(agentId)) next.delete(agentId);
      else next.add(agentId);
      return next;
    });
  }

  function selectAllResults() {
    setSelectedResults(new Set(resultsArray.map(r => r.agent_id)));
  }

  function deselectAllResults() {
    setSelectedResults(new Set());
  }

  function getAgentStats(): AgentStats[] {
    const statsMap = new Map<string, { name: string; emoji: string; runs: number; totalCost: number; successes: number; failures: number }>();
    for (const r of resultsArray) {
      const existing = statsMap.get(r.agent_id) || { name: r.agent_name, emoji: '🤖', runs: 0, totalCost: 0, successes: 0, failures: 0 };
      existing.runs++;
      existing.totalCost += r.cost_usd;
      if (r.status === 'completed') existing.successes++;
      else if (r.status === 'error') existing.failures++;
      statsMap.set(r.agent_id, existing);
    }
    return Array.from(statsMap.entries()).map(([id, s]) => ({
      id, ...s,
      totalTime: 0,
      avgTime: 0,
      successRate: s.runs > 0 ? (s.successes / s.runs * 100) : 0,
    }));
  }

  return {
    streamResults,
    setStreamResults,
    activeSession,
    setActiveSession,
    expandedCards,
    compareMode,
    setCompareMode,
    bookmarks,
    ratings,
    selectedResults,
    resultsRef,
    resultsArray,
    totalCost,
    totalTokens,
    clearResults,
    toggleCardExpanded,
    toggleBookmark,
    toggleRating,
    toggleResultSelect,
    selectAllResults,
    deselectAllResults,
    getAgentStats,
  };
}
