import { create } from 'zustand';
import type { Theme, SidebarSections, OfficeAgent, Agent, ActivityEntry } from '../types';
import { loadString, saveString, loadJson, saveJson } from '../utils/storage';
import { STORAGE_KEYS } from '../utils/constants';

function loadNumber(key: string, fallback: number): number {
  try {
    const raw = localStorage.getItem(key);
    return raw ? parseFloat(raw) : fallback;
  } catch {
    return fallback;
  }
}

interface AppState {
  // Settings
  theme: Theme;
  provider: string;
  costBudget: number;
  sidebarSections: SidebarSections;
  compactOffice: boolean;

  // Office
  officeAgents: OfficeAgent[];
  agentGroups: Record<string, string[]>;
  officePresets: Record<string, OfficeAgent[]>;
  groupName: string;
  presetName: string;
  showGroupSave: boolean;
  showPresetSave: boolean;

  // UI
  showSettings: boolean;
  showHelp: boolean;
  showResultsPanel: boolean;
  showPerfDashboard: boolean;

  // Toast
  toast: { message: string; type: 'error' | 'success' } | null;

  // Activity
  activityLog: ActivityEntry[];
}

interface AppActions {
  // Settings
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
  setProvider: (provider: string) => void;
  setCostBudget: (budget: number) => void;
  setSidebarSections: (sections: SidebarSections | ((prev: SidebarSections) => SidebarSections)) => void;
  setCompactOffice: (compact: boolean) => void;

  // Office
  setOfficeAgents: (agents: OfficeAgent[] | ((prev: OfficeAgent[]) => OfficeAgent[])) => void;
  seatAgentAtRole: (agent: Agent, role: string) => void;
  removeFromDesk: (role: string) => void;
  clearOffice: () => void;
  loadGroup: (name: string, allAgents: Agent[], setSelected: (ids: string[]) => void) => void;
  deleteGroup: (name: string) => void;
  loadOfficePreset: (name: string) => void;
  deleteOfficePreset: (name: string) => void;
  setGroupName: (name: string) => void;
  setPresetName: (name: string) => void;
  setShowGroupSave: (show: boolean) => void;
  setShowPresetSave: (show: boolean) => void;

  // UI
  setShowSettings: (show: boolean) => void;
  setShowHelp: (show: boolean) => void;
  setShowResultsPanel: (show: boolean) => void;
  setShowPerfDashboard: (show: boolean) => void;

  // Toast
  showToast: (message: string, type?: 'error' | 'success') => void;
  dismissToast: () => void;

  // Activity
  logActivity: (message: string, type: 'info' | 'success' | 'warning' | 'error') => void;
  clearActivityLog: () => void;
}

export const useAppStore = create<AppState & AppActions>((set, get) => ({
  // Settings - hydrated from localStorage
  theme: loadString(STORAGE_KEYS.theme, 'system') as Theme,
  provider: loadString(STORAGE_KEYS.provider, 'anthropic'),
  costBudget: loadNumber(STORAGE_KEYS.budget, 0),
  sidebarSections: loadJson<SidebarSections>(STORAGE_KEYS.sidebarSections, { groups: true, presets: true, agents: true }),
  compactOffice: loadString(STORAGE_KEYS.compact, 'false') === 'true',

  // Office
  officeAgents: loadJson<OfficeAgent[]>(STORAGE_KEYS.seats, []),
  agentGroups: loadJson<Record<string, string[]>>(STORAGE_KEYS.groups, {}),
  officePresets: loadJson<Record<string, OfficeAgent[]>>(STORAGE_KEYS.presets, {}),
  groupName: '',
  presetName: '',
  showGroupSave: false,
  showPresetSave: false,

  // UI
  showSettings: false,
  showHelp: false,
  showResultsPanel: true,
  showPerfDashboard: false,

  // Toast
  toast: null,

  // Activity
  activityLog: [],

  // --- Actions ---

  setTheme: (theme) => {
    saveString(STORAGE_KEYS.theme, theme);
    const resolved = theme === 'system'
      ? (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
      : theme;
    document.documentElement.setAttribute('data-theme', resolved);
    set({ theme });
  },

  toggleTheme: () => {
    const current = get().theme;
    const resolved = current === 'system'
      ? (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
      : current;
    const next = resolved === 'dark' ? 'light' : 'dark';
    get().setTheme(next);
  },

  setProvider: (provider) => {
    saveString(STORAGE_KEYS.provider, provider);
    set({ provider });
  },

  setCostBudget: (costBudget) => {
    saveNumber(STORAGE_KEYS.budget, costBudget);
    set({ costBudget });
  },

  setSidebarSections: (sectionsOrFn) => {
    const prev = get().sidebarSections;
    const next = typeof sectionsOrFn === 'function' ? sectionsOrFn(prev) : sectionsOrFn;
    saveJson(STORAGE_KEYS.sidebarSections, next);
    set({ sidebarSections: next });
  },

  setCompactOffice: (compactOffice) => {
    saveString(STORAGE_KEYS.compact, String(compactOffice));
    set({ compactOffice });
  },

  setOfficeAgents: (agentsOrFn) => {
    const prev = get().officeAgents;
    const next = typeof agentsOrFn === 'function' ? agentsOrFn(prev) : agentsOrFn;
    saveJson(STORAGE_KEYS.seats, next);
    set({ officeAgents: next });
  },

  seatAgentAtRole: (agent, role) => {
    set((s) => {
      const existing = s.officeAgents.filter((o) => o.role !== role);
      const newSeat: OfficeAgent = {
        id: agent.id,
        name: agent.name,
        role,
        emoji: agent.emoji,
        status: 'idle',
      };
      const next = [...existing, newSeat];
      saveJson(STORAGE_KEYS.seats, next);
      return { officeAgents: next };
    });
  },

  removeFromDesk: (role) => {
    set((s) => {
      const next = s.officeAgents.filter((o) => o.role !== role);
      saveJson(STORAGE_KEYS.seats, next);
      return { officeAgents: next };
    });
  },

  clearOffice: () => {
    saveJson(STORAGE_KEYS.seats, []);
    set({ officeAgents: [] });
  },

  loadGroup: (name, allAgents, setSelected) => {
    const group = get().agentGroups[name];
    if (group) {
      setSelected(group);
    }
  },

  deleteGroup: (name) => {
    set((s) => {
      const next = { ...s.agentGroups };
      delete next[name];
      saveJson(STORAGE_KEYS.groups, next);
      return { agentGroups: next };
    });
  },

  loadOfficePreset: (name) => {
    const preset = get().officePresets[name];
    if (preset) {
      saveJson(STORAGE_KEYS.seats, preset);
      set({ officeAgents: preset });
    }
  },

  deleteOfficePreset: (name) => {
    set((s) => {
      const next = { ...s.officePresets };
      delete next[name];
      saveJson(STORAGE_KEYS.presets, next);
      return { officePresets: next };
    });
  },

  setGroupName: (groupName) => set({ groupName }),
  setPresetName: (presetName) => set({ presetName }),
  setShowGroupSave: (showGroupSave) => set({ showGroupSave }),
  setShowPresetSave: (showPresetSave) => set({ showPresetSave }),

  setShowSettings: (showSettings) => set({ showSettings }),
  setShowHelp: (showHelp) => set({ showHelp }),
  setShowResultsPanel: (showResultsPanel) => set({ showResultsPanel }),
  setShowPerfDashboard: (showPerfDashboard) => set({ showPerfDashboard }),

  showToast: (message, type = 'success') => {
    set({ toast: { message, type } });
    const prev = (globalThis as Record<string, unknown>).__toastTimer as number | undefined;
    if (prev) clearTimeout(prev);
    (globalThis as Record<string, unknown>).__toastTimer = setTimeout(() => set({ toast: null }), 3000);
  },

  dismissToast: () => set({ toast: null }),

  logActivity: (message, type) => {
    if (!message) return;
    const entry: ActivityEntry = {
      id: crypto.randomUUID(),
      message,
      type,
      timestamp: new Date().toISOString(),
    };
    set((s) => ({ activityLog: [entry, ...s.activityLog].slice(0, 50) }));
  },

  clearActivityLog: () => set({ activityLog: [] }),
}));

function saveNumber(key: string, value: number): void {
  try {
    localStorage.setItem(key, String(value));
  } catch {
    /* noop */
  }
}
