import { useState, useCallback } from 'react';
import { loadJson, saveJson } from '../utils/storage';

const STORAGE_KEY = 'agent-office-prompt-templates';

export interface PromptTemplate {
  id: string;
  name: string;
  prompt: string;
  tags: string[];
  createdAt: string;
}

export function usePromptTemplates() {
  const [templates, setTemplates] = useState<PromptTemplate[]>(() =>
    loadJson<PromptTemplate[]>(STORAGE_KEY, [])
  );

  const addTemplate = useCallback((name: string, prompt: string, tags: string[] = []) => {
    const template: PromptTemplate = {
      id: crypto.randomUUID(),
      name,
      prompt,
      tags,
      createdAt: new Date().toISOString(),
    };
    setTemplates(prev => {
      const next = [template, ...prev].slice(0, 100);
      saveJson(STORAGE_KEY, next);
      return next;
    });
    return template;
  }, []);

  const updateTemplate = useCallback((id: string, updates: Partial<Omit<PromptTemplate, 'id' | 'createdAt'>>) => {
    setTemplates(prev => {
      const next = prev.map(t => t.id === id ? { ...t, ...updates } : t);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const deleteTemplate = useCallback((id: string) => {
    setTemplates(prev => {
      const next = prev.filter(t => t.id !== id);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const searchTemplates = useCallback((query: string): PromptTemplate[] => {
    if (!query.trim()) return templates;
    const lower = query.toLowerCase();
    return templates.filter(t =>
      t.name.toLowerCase().includes(lower) ||
      t.prompt.toLowerCase().includes(lower) ||
      t.tags.some(tag => tag.toLowerCase().includes(lower))
    );
  }, [templates]);

  const getTemplatesByTag = useCallback((tag: string): PromptTemplate[] => {
    return templates.filter(t => t.tags.includes(tag));
  }, [templates]);

  const getAllTags = useCallback((): string[] => {
    const tagSet = new Set<string>();
    for (const t of templates) {
      for (const tag of t.tags) {
        tagSet.add(tag);
      }
    }
    return [...tagSet].sort();
  }, [templates]);

  return {
    templates,
    addTemplate,
    updateTemplate,
    deleteTemplate,
    searchTemplates,
    getTemplatesByTag,
    getAllTags,
  };
}
