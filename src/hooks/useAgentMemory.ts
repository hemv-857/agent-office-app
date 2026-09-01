import { useState, useCallback } from 'react';
import { loadJson, saveJson } from '../utils/storage';

const STORAGE_KEY = 'agent-office-agent-memory';

export interface AgentMemory {
  agentId: string;
  entries: MemoryEntry[];
}

export interface MemoryEntry {
  id: string;
  timestamp: string;
  task: string;
  lesson: string;
  tags: string[];
}

function genId(): string {
  return crypto.randomUUID();
}

export function useAgentMemory() {
  const [memories, setMemories] = useState<AgentMemory[]>(() =>
    loadJson<AgentMemory[]>(STORAGE_KEY, [])
  );

  const addMemory = useCallback((agentId: string, task: string, lesson: string, tags: string[] = []) => {
    setMemories(prev => {
      const existing = prev.find(m => m.agentId === agentId);
      const entry: MemoryEntry = {
        id: genId(),
        timestamp: new Date().toISOString(),
        task,
        lesson,
        tags,
      };
      let next: AgentMemory[];
      if (existing) {
        next = prev.map(m =>
          m.agentId === agentId
            ? { ...m, entries: [entry, ...m.entries].slice(0, 50) }
            : m
        );
      } else {
        next = [...prev, { agentId, entries: [entry] }];
      }
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const getMemories = useCallback((agentId: string): MemoryEntry[] => {
    const found = memories.find(m => m.agentId === agentId);
    return found?.entries || [];
  }, [memories]);

  const searchMemories = useCallback((query: string): AgentMemory[] => {
    if (!query.trim()) return memories;
    const lower = query.toLowerCase();
    return memories
      .map(m => ({
        ...m,
        entries: m.entries.filter(
          e => e.lesson.toLowerCase().includes(lower) ||
               e.task.toLowerCase().includes(lower) ||
               e.tags.some(t => t.toLowerCase().includes(lower))
        ),
      }))
      .filter(m => m.entries.length > 0);
  }, [memories]);

  const deleteMemory = useCallback((agentId: string, entryId: string) => {
    setMemories(prev => {
      const next = prev
        .map(m => m.agentId === agentId
          ? { ...m, entries: m.entries.filter(e => e.id !== entryId) }
          : m
        )
        .filter(m => m.entries.length > 0);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const clearAgentMemories = useCallback((agentId: string) => {
    setMemories(prev => {
      const next = prev.filter(m => m.agentId !== agentId);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const formatForPrompt = useCallback((agentId: string): string => {
    const entries = getMemories(agentId);
    if (entries.length === 0) return '';
    const recent = entries.slice(0, 10);
    return '\n\nAGENT MEMORY (lessons from past tasks):\n' +
      recent.map(e => `- [${e.tags.join(', ')}] ${e.lesson}`).join('\n');
  }, [getMemories]);

  return {
    memories,
    addMemory,
    getMemories,
    searchMemories,
    deleteMemory,
    clearAgentMemories,
    formatForPrompt,
  };
}
