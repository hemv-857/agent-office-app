import { describe, it, expect, beforeEach } from 'vitest';

describe('useAgentMemory', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  const STORAGE_KEY = 'agent-office-agent-memory';

  function loadMemories() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  function saveMemories(entries: unknown[]) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  }

  it('starts empty', () => {
    expect(loadMemories()).toEqual([]);
  });

  it('stores agent memories', () => {
    const memories = [{
      agentId: 'agent-1',
      entries: [{
        id: '1',
        timestamp: new Date().toISOString(),
        task: 'code review',
        lesson: 'Always check for null pointers',
        tags: ['safety', 'patterns'],
      }],
    }];
    saveMemories(memories);
    expect(loadMemories()).toHaveLength(1);
    expect(loadMemories()[0].entries).toHaveLength(1);
  });

  it('searches by lesson content', () => {
    const memories = [
      { agentId: 'a', entries: [{ lesson: 'Check for null pointers', task: 'review', tags: ['safety'] }] },
      { agentId: 'b', entries: [{ lesson: 'Use meaningful variable names', task: 'refactor', tags: ['style'] }] },
    ];
    saveMemories(memories);
    const query = 'null';
    const results = loadMemories().filter((m: { entries: { lesson: string }[] }) =>
      m.entries.some((e: { lesson: string }) => e.lesson.toLowerCase().includes(query.toLowerCase()))
    );
    expect(results).toHaveLength(1);
    expect(results[0].agentId).toBe('a');
  });

  it('formats memory for prompt injection', () => {
    const memories = [{
      agentId: 'agent-1',
      entries: [
        { lesson: 'Always validate inputs', tags: ['security'] },
        { lesson: 'Use early returns', tags: ['patterns'] },
      ],
    }];
    saveMemories(memories);
    const agentMemories = loadMemories().find((m: { agentId: string }) => m.agentId === 'agent-1');
    const formatted = agentMemories.entries
      .map((e: { tags: string[]; lesson: string }) => `- [${e.tags.join(', ')}] ${e.lesson}`)
      .join('\n');
    expect(formatted).toContain('[security] Always validate inputs');
    expect(formatted).toContain('[patterns] Use early returns');
  });
});
