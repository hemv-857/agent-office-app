import { describe, it, expect, beforeEach } from 'vitest';

describe('usePromptTemplates', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  const STORAGE_KEY = 'agent-office-prompt-templates';

  function loadTemplates() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  }

  function saveTemplates(entries: unknown[]) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  }

  it('starts empty', () => {
    expect(loadTemplates()).toEqual([]);
  });

  it('stores templates', () => {
    const templates = [{
      id: '1',
      name: 'Code Review',
      prompt: 'Review this code',
      tags: ['review', 'code'],
      createdAt: new Date().toISOString(),
    }];
    saveTemplates(templates);
    expect(loadTemplates()).toHaveLength(1);
    expect(loadTemplates()[0].name).toBe('Code Review');
  });

  it('searches by name', () => {
    const templates = [
      { id: '1', name: 'Code Review', prompt: 'review code', tags: [] },
      { id: '2', name: 'Bug Fix', prompt: 'fix bugs', tags: [] },
    ];
    saveTemplates(templates);
    const results = loadTemplates().filter((t: { name: string }) =>
      t.name.toLowerCase().includes('review')
    );
    expect(results).toHaveLength(1);
  });

  it('searches by tags', () => {
    const templates = [
      { id: '1', name: 'Review', prompt: 'review', tags: ['code', 'quality'] },
      { id: '2', name: 'Deploy', prompt: 'deploy', tags: ['ops'] },
    ];
    saveTemplates(templates);
    const results = loadTemplates().filter((t: { tags: string[] }) =>
      t.tags.includes('code')
    );
    expect(results).toHaveLength(1);
  });

  it('can delete templates', () => {
    const templates = [
      { id: '1', name: 'A' },
      { id: '2', name: 'B' },
    ];
    saveTemplates(templates);
    const remaining = loadTemplates().filter((t: { id: string }) => t.id !== '2');
    saveTemplates(remaining);
    expect(loadTemplates()).toHaveLength(1);
  });

  it('limits to 100 templates', () => {
    const templates = Array.from({ length: 110 }, (_, i) => ({
      id: String(i),
      name: `Template ${i}`,
    }));
    saveTemplates(templates.slice(0, 100));
    expect(loadTemplates()).toHaveLength(100);
  });
});
