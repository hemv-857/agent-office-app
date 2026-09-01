import { useState } from 'react';
import { invoke } from '@tauri-apps/api/core';
import type { Suggestion, Agent, OfficeAgent } from '../types';
import { loadJson, saveJson } from '../utils/storage';
import { STORAGE_KEYS } from '../utils/constants';
import { useAppStore } from '../store/useAppStore';

type SetOfficeAgents = (agents: OfficeAgent[] | ((prev: OfficeAgent[]) => OfficeAgent[])) => void;

interface UseOrchestrationProps {
  prompt: string;
  setPrompt: (v: string) => void;
  selectedAgents: string[];
  setSelectedAgents: (ids: string[]) => void;
  isRunning: boolean;
  setIsRunning: (v: boolean) => void;
  provider: string;
  allAgents: Agent[];
  showToast: (msg: string, type?: 'error' | 'success') => void;
}

export function useOrchestration({
  prompt,
  setPrompt,
  selectedAgents,
  setSelectedAgents,
  isRunning,
  setIsRunning,
  provider,
  allAgents,
  showToast,
}: UseOrchestrationProps) {
  const [promptHistory, setPromptHistory] = useState<string[]>(() =>
    loadJson<string[]>(STORAGE_KEYS.prompts, [])
  );
  const [suggesting, setSuggesting] = useState(false);
  const [suggestions, setSuggestions] = useState<Suggestion | null>(null);
  const [promptQueue, setPromptQueue] = useState<string[]>([]);

  const setOfficeAgents: SetOfficeAgents = useAppStore(s => s.setOfficeAgents);
  const seatAgentAtRole = useAppStore(s => s.seatAgentAtRole);

  function savePromptToHistory(promptText: string) {
    setPromptHistory(prev => {
      const next = [promptText, ...prev.filter(p => p !== promptText)].slice(0, 5);
      saveJson(STORAGE_KEYS.prompts, next);
      return next;
    });
  }

  async function handleSubmit() {
    if (!prompt.trim() || selectedAgents.length === 0 || isRunning) return;

    savePromptToHistory(prompt.trim());
    setIsRunning(true);
    useAppStore.getState().logActivity(`Dispatched ${selectedAgents.length} agents (${provider})`, 'info');

    selectedAgents.forEach(id => {
      const agent = allAgents.find(a => a.id === id);
      if (agent) seatAgentAtRole(agent, agent.office_role);
    });

    setOfficeAgents(prev =>
      prev.map(a => selectedAgents.includes(a.id) ? { ...a, status: 'working' } : a)
    );

    try {
      await invoke('execute_task', {
        request: {
          prompt: prompt.trim(),
          agent_ids: selectedAgents,
          provider,
          model: null,
          temperature: 0.7,
        }
      });
    } catch (e) {
      const msg = typeof e === 'string' ? e : 'Task failed';
      showToast(msg, 'error');
      selectedAgents.forEach(id => {
        setOfficeAgents(prev =>
          prev.map(a => a.id === id ? { ...a, status: 'blocked' } : a)
        );
      });
    } finally {
      setIsRunning(false);
    }
  }

  async function handleSuggest() {
    if (!prompt.trim()) {
      showToast('Type a prompt first', 'error');
      return;
    }
    setSuggesting(true);
    setSuggestions(null);
    try {
      const result: { agent_ids: string[]; reasoning: string } = await invoke('analyze_prompt', {
        prompt: prompt.trim(),
        provider,
      });
      setSuggestions({ agentIds: result.agent_ids, reasoning: result.reasoning });
      setSelectedAgents(result.agent_ids);

      result.agent_ids.forEach((id: string) => {
        const agent = allAgents.find(a => a.id === id);
        if (agent) {
          const role = agent.office_role;
          seatAgentAtRole(agent, role);
        }
      });
    } catch (e) {
      showToast(typeof e === 'string' ? e : 'Head Agent failed', 'error');
    } finally {
      setSuggesting(false);
    }
  }

  function addToQueue() {
    if (!prompt.trim()) return;
    setPromptQueue(prev => [...prev, prompt.trim()]);
    setPrompt('');
    showToast('Added to queue', 'success');
  }

  function clearQueue() {
    setPromptQueue([]);
  }

  return {
    promptHistory,
    suggesting,
    suggestions,
    setSuggestions,
    promptQueue,
    setPromptQueue,
    handleSubmit,
    handleSuggest,
    addToQueue,
    clearQueue,
  };
}
