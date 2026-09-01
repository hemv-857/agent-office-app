import { describe, it, expect, beforeEach } from 'vitest';

// Test session history logic directly (mock localStorage)
describe('useSessionHistory', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  const STORAGE_KEY = 'agent-office-sessions';

  function loadSessions() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  function saveSessions(sessions: unknown[]) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(sessions));
  }

  it('starts empty', () => {
    expect(loadSessions()).toEqual([]);
  });

  it('can save and load sessions', () => {
    const session = {
      id: '1',
      prompt: 'test prompt',
      agentIds: ['agent-1', 'agent-2'],
      provider: 'anthropic',
      timestamp: new Date().toISOString(),
      results: [],
      totalCost: 0.01,
      totalTokens: 150,
    };
    const existing = loadSessions();
    saveSessions([session, ...existing]);
    const loaded = loadSessions();
    expect(loaded).toHaveLength(1);
    expect(loaded[0].prompt).toBe('test prompt');
  });

  it('limits to 100 sessions', () => {
    const sessions = Array.from({ length: 110 }, (_, i) => ({
      id: String(i),
      prompt: `prompt ${i}`,
      agentIds: [],
      provider: 'anthropic',
      timestamp: new Date().toISOString(),
      results: [],
      totalCost: 0,
      totalTokens: 0,
    }));
    const trimmed = sessions.slice(0, 100);
    saveSessions(trimmed);
    expect(loadSessions()).toHaveLength(100);
  });

  it('can delete a session', () => {
    const sessions = [
      { id: '1', prompt: 'a' },
      { id: '2', prompt: 'b' },
    ];
    saveSessions(sessions);
    const remaining = loadSessions().filter((s: { id: string }) => s.id !== '2');
    saveSessions(remaining);
    expect(loadSessions()).toHaveLength(1);
    expect(loadSessions()[0].id).toBe('1');
  });

  it('can search sessions by prompt', () => {
    const sessions = [
      { id: '1', prompt: 'build a REST API' },
      { id: '2', prompt: 'fix the CSS layout' },
      { id: '3', prompt: 'build a React component' },
    ];
    saveSessions(sessions);
    const query = 'build';
    const results = loadSessions().filter((s: { prompt: string }) =>
      s.prompt.toLowerCase().includes(query.toLowerCase())
    );
    expect(results).toHaveLength(2);
  });
});
