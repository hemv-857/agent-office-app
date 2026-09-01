import { useState } from 'react';
import type { Agent } from '../types';
import { ROLE_MAP } from '../utils/constants';
import { useAppStore } from '../store/useAppStore';

export function useOffice() {
  const {
    officeAgents, seatAgentAtRole: storeSeat, removeFromDesk: storeRemove,
    clearOffice: storeClear, deleteGroup, loadOfficePreset: storeLoadPreset, deleteOfficePreset,
    agentGroups, officePresets,
  } = useAppStore();

  const [dragOverRole, setDragOverRole] = useState<string | null>(null);

  function handleDragStart(e: React.DragEvent, agent: Agent) {
    e.dataTransfer.setData('application/json', JSON.stringify(agent));
    e.dataTransfer.effectAllowed = 'copy';
  }

  function handleDragOver(e: React.DragEvent, role: string) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
    setDragOverRole(role);
  }

  function handleDragLeave() {
    setDragOverRole(null);
  }

  function handleDrop(e: React.DragEvent, role: string) {
    e.preventDefault();
    setDragOverRole(null);
    try {
      const agent: Agent = JSON.parse(e.dataTransfer.getData('application/json'));
      storeSeat(agent, role);
    } catch { /* invalid drag data */ }
  }

  function handleAgentDoubleClick(agent: Agent) {
    storeSeat(agent, agent.office_role);
  }

  function handleDeskDragStart(e: React.DragEvent, role: string) {
    e.dataTransfer.setData('text/plain', role);
    e.dataTransfer.effectAllowed = 'move';
  }

  function handleDeskDrop(e: React.DragEvent, targetRole: string) {
    e.preventDefault();
    setDragOverRole(null);
    const sourceRole = e.dataTransfer.getData('text/plain');
    if (sourceRole && sourceRole !== targetRole) {
      useAppStore.setState(s => {
        const source = s.officeAgents.find(a => a.role === sourceRole);
        const target = s.officeAgents.find(a => a.role === targetRole);
        if (!source && !target) return s;
        const next = s.officeAgents.map(a => {
          if (a.role === sourceRole && target) return { ...a, role: targetRole };
          if (a.role === targetRole && source) return { ...a, role: sourceRole };
          return a;
        });
        return { officeAgents: next };
      });
    }
  }

  function loadGroup(name: string, allAgents: Agent[], setSelectedAgents: (ids: string[]) => void) {
    const ids = agentGroups[name];
    if (!ids) return;
    setSelectedAgents(ids);
    const seats = ids.map(id => {
      const agent = allAgents.find(a => a.id === id);
      if (!agent) return null;
      const role = ROLE_MAP[agent.office_role] || 'dev';
      return { id, name: agent.name, emoji: agent.emoji, role, status: 'idle' as const, message: '' };
    }).filter((a): a is NonNullable<typeof a> => a !== null);
    useAppStore.setState(s => ({
      officeAgents: [...s.officeAgents.filter(a => !ids.includes(a.id)), ...seats],
    }));
  }

  function saveGroup(name: string, agentIds: string[]) {
    if (!name.trim() || agentIds.length === 0) return false;
    useAppStore.setState(s => {
      const next = { ...s.agentGroups, [name.trim()]: [...agentIds] };
      return { agentGroups: next, showGroupSave: false, groupName: '' };
    });
    return true;
  }

  function saveOfficePreset(presetName: string) {
    if (!presetName.trim()) return false;
    const agents = officeAgents.map(a => ({ id: a.id, name: a.name, role: a.role, emoji: a.emoji, status: a.status, message: '' }));
    useAppStore.setState(s => {
      const next = { ...s.officePresets, [presetName.trim()]: agents };
      return { officePresets: next, showPresetSave: false, presetName: '' };
    });
    return true;
  }

  return {
    officeAgents,
    dragOverRole,
    setDragOverRole,
    agentGroupsArray: Object.entries(agentGroups).map(([name, agentIds]) => ({ name, agentIds })),
    officePresetsArray: Object.entries(officePresets).map(([name, agents]) => ({ name, agents })),
    seatAgentAtRole: storeSeat,
    removeFromDesk: storeRemove,
    clearOffice: storeClear,
    handleDragStart,
    handleDragOver,
    handleDragLeave,
    handleDrop,
    handleAgentDoubleClick,
    handleDeskDragStart,
    handleDeskDrop,
    loadGroup,
    saveGroup,
    deleteGroup,
    saveOfficePreset,
    loadOfficePreset: storeLoadPreset,
    deleteOfficePreset,
  };
}
