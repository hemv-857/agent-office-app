import { useState, useEffect, useMemo } from 'react';
import { invoke } from '@tauri-apps/api/core';
import type { Agent, AgentDetail, CustomAgentForm } from '../types';
import { loadJson, saveJson } from '../utils/storage';
import { STORAGE_KEYS, DEFAULT_CUSTOM_AGENT } from '../utils/constants';

export function useAgentCatalog() {
  const [agents, setAgents] = useState<Agent[]>([]);
  const [customAgents, setCustomAgents] = useState<Agent[]>(() =>
    loadJson<Agent[]>(STORAGE_KEYS.customAgents, [])
  );
  const [agentDetail, setAgentDetail] = useState<AgentDetail | null>(null);
  const [showCustomAgent, setShowCustomAgent] = useState(false);
  const [customForm, setCustomForm] = useState<CustomAgentForm>(DEFAULT_CUSTOM_AGENT);

  useEffect(() => {
    let cancelled = false;
    invoke<Agent[]>('get_agents')
      .then(list => { if (!cancelled) setAgents(list); })
      .catch(e => console.error('Failed to load agents:', e));
    return () => { cancelled = true; };
  }, []);

  useEffect(() => {
    saveJson(STORAGE_KEYS.customAgents, customAgents);
  }, [customAgents]);

  const allAgents = useMemo(() => {
    return [...agents, ...customAgents];
  }, [agents, customAgents]);

  const divisions = useMemo(() => {
    const allDivs = allAgents.map(a => a.division);
    return [...new Set(allDivs)].sort();
  }, [allAgents]);

  function addCustomAgent() {
    if (!customForm.name.trim() || !customForm.system_prompt.trim()) {
      return false;
    }
    const id = `custom-${crypto.randomUUID()}`;
    setCustomAgents(prev => [...prev, { ...customForm, id }]);
    setCustomForm(DEFAULT_CUSTOM_AGENT);
    setShowCustomAgent(false);
    return true;
  }

  async function showAgentDetail(agentId: string) {
    try {
      const detail = await invoke<AgentDetail>('get_agent_detail', { agentId });
      setAgentDetail(detail);
    } catch (e) {
      console.error('Failed to load agent details:', e);
    }
  }

  return {
    agents,
    customAgents,
    allAgents,
    divisions,
    agentDetail,
    setAgentDetail,
    showCustomAgent,
    setShowCustomAgent,
    customForm,
    setCustomForm,
    addCustomAgent,
    showAgentDetail,
  };
}
