import { describe, it, expect, beforeEach } from 'vitest';
import { useAppStore } from '../../store/useAppStore';

describe('useAppStore', () => {
  beforeEach(() => {
    localStorage.clear();
    // Reset store to defaults
    const store = useAppStore.getState();
    store.setTheme('dark');
    store.setProvider('anthropic');
    store.setCostBudget(0);
    store.clearOffice();
  });

  describe('theme', () => {
    it('has default dark theme', () => {
      expect(useAppStore.getState().theme).toBe('dark');
    });

    it('toggles theme', () => {
      const store = useAppStore.getState();
      store.toggleTheme();
      expect(useAppStore.getState().theme).toBe('light');
      store.toggleTheme();
      expect(useAppStore.getState().theme).toBe('dark');
    });

    it('persists to localStorage', () => {
      useAppStore.getState().setTheme('light');
      expect(localStorage.getItem('agent-office-theme')).toBe('light');
    });
  });

  describe('provider', () => {
    it('defaults to anthropic', () => {
      expect(useAppStore.getState().provider).toBe('anthropic');
    });

    it('persists to localStorage', () => {
      useAppStore.getState().setProvider('openai');
      expect(localStorage.getItem('agent-office-provider')).toBe('openai');
    });
  });

  describe('office agents', () => {
    it('starts empty', () => {
      expect(useAppStore.getState().officeAgents).toEqual([]);
    });

    it('clears office', () => {
      const store = useAppStore.getState();
      store.setOfficeAgents([{ id: '1', name: 'Test', role: 'dev', emoji: '🔧', status: 'idle' }]);
      expect(useAppStore.getState().officeAgents).toHaveLength(1);
      store.clearOffice();
      expect(useAppStore.getState().officeAgents).toHaveLength(0);
    });
  });

  describe('toast', () => {
    it('shows and dismisses toast', () => {
      const store = useAppStore.getState();
      store.showToast('Hello', 'success');
      expect(useAppStore.getState().toast?.message).toBe('Hello');
      store.dismissToast();
      expect(useAppStore.getState().toast).toBeNull();
    });
  });

  describe('activity log', () => {
    it('adds entries', () => {
      useAppStore.getState().logActivity('test message', 'info');
      const log = useAppStore.getState().activityLog;
      expect(log).toHaveLength(1);
      expect(log[0].message).toBe('test message');
      expect(log[0].type).toBe('info');
    });

    it('limits to 50 entries', () => {
      const store = useAppStore.getState();
      for (let i = 0; i < 60; i++) {
        store.logActivity(`entry ${i}`, 'info');
      }
      expect(useAppStore.getState().activityLog).toHaveLength(50);
    });
  });

  describe('cost budget', () => {
    it('persists to localStorage', () => {
      useAppStore.getState().setCostBudget(10.5);
      expect(localStorage.getItem('agent-office-budget')).toBe('10.5');
    });
  });
});
