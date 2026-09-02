import { describe, it, expect, beforeEach } from 'vitest';
import { useAppStore } from '../useAppStore';

describe('useAppStore - integration', () => {
  beforeEach(() => {
    localStorage.clear();
    const store = useAppStore.getState();
    store.setTheme('dark');
    store.setProvider('anthropic');
    store.setCostBudget(0);
    store.clearOffice();
  });

  it('seatAgentAtRole adds agent to office', () => {
    const store = useAppStore.getState();
    const agent = {
      id: 'test-1',
      name: 'Test Dev',
      office_role: 'dev',
      emoji: '',
    } as Parameters<typeof store.seatAgentAtRole>[0];

    store.seatAgentAtRole(agent, 'dev');
    const agents = useAppStore.getState().officeAgents;
    expect(agents).toHaveLength(1);
    expect(agents[0].id).toBe('test-1');
    expect(agents[0].role).toBe('dev');
  });

  it('seatAgentAtRole replaces existing agent at same role', () => {
    const store = useAppStore.getState();
    store.seatAgentAtRole({ id: 'a1', name: 'Agent 1', office_role: 'dev', emoji: '1' } as never, 'dev');
    store.seatAgentAtRole({ id: 'a2', name: 'Agent 2', office_role: 'dev', emoji: '2' } as never, 'dev');
    const agents = useAppStore.getState().officeAgents;
    expect(agents).toHaveLength(1);
    expect(agents[0].id).toBe('a2');
  });

  it('removeFromDesk removes agent from role', () => {
    const store = useAppStore.getState();
    store.seatAgentAtRole({ id: 'a1', name: 'Agent 1', office_role: 'dev', emoji: '1' } as never, 'dev');
    store.removeFromDesk('dev');
    expect(useAppStore.getState().officeAgents).toHaveLength(0);
  });

  it('toggleTheme toggles between dark and light', () => {
    const store = useAppStore.getState();
    expect(store.theme).toBe('dark');
    store.toggleTheme();
    expect(useAppStore.getState().theme).toBe('light');
    store.toggleTheme();
    expect(useAppStore.getState().theme).toBe('dark');
  });

  it('setProvider persists to localStorage', () => {
    useAppStore.getState().setProvider('openai');
    expect(localStorage.getItem('agent-office-provider')).toBe('openai');
    expect(useAppStore.getState().provider).toBe('openai');
  });

  it('showToast creates and auto-dismisses toast', async () => {
    const store = useAppStore.getState();
    store.showToast('Test message', 'success');
    expect(useAppStore.getState().toast?.message).toBe('Test message');

    // Wait for auto-dismiss (3000ms + buffer)
    await new Promise(r => setTimeout(r, 3200));
    expect(useAppStore.getState().toast).toBeNull();
  });

  it('logActivity adds entries with timestamps', () => {
    const store = useAppStore.getState();
    store.logActivity('Test activity', 'success');
    const log = useAppStore.getState().activityLog;
    expect(log).toHaveLength(1);
    expect(log[0].message).toBe('Test activity');
    expect(log[0].type).toBe('success');
    expect(log[0].timestamp).toBeTruthy();
    expect(log[0].id).toBeTruthy();
  });

  it('logActivity limits to 50 entries', () => {
    const store = useAppStore.getState();
    for (let i = 0; i < 60; i++) {
      store.logActivity(`entry ${i}`, 'info');
    }
    expect(useAppStore.getState().activityLog).toHaveLength(50);
  });

  it('setSidebarSections toggles individual sections', () => {
    const store = useAppStore.getState();
    expect(store.sidebarSections.groups).toBe(true);
    store.setSidebarSections(prev => ({ ...prev, groups: false }));
    expect(useAppStore.getState().sidebarSections.groups).toBe(false);
  });

  it('setCostBudget persists to localStorage', () => {
    useAppStore.getState().setCostBudget(25.5);
    expect(localStorage.getItem('agent-office-budget')).toBe('25.5');
    expect(useAppStore.getState().costBudget).toBe(25.5);
  });
});
