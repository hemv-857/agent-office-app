import { useState, useCallback } from 'react';
import { loadJson, saveJson } from '../utils/storage';

const STORAGE_KEY = 'agent-office-session-notes';

export interface SessionNote {
  id: string;
  sessionId: string;
  content: string;
  tags: string[];
  createdAt: string;
  updatedAt: string;
}

export function useSessionNotes() {
  const [notes, setNotes] = useState<SessionNote[]>(() =>
    loadJson<SessionNote[]>(STORAGE_KEY, [])
  );

  const addNote = useCallback((sessionId: string, content: string, tags: string[] = []) => {
    const note: SessionNote = {
      id: crypto.randomUUID(),
      sessionId,
      content,
      tags,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    setNotes(prev => {
      const next = [note, ...prev].slice(0, 500);
      saveJson(STORAGE_KEY, next);
      return next;
    });
    return note;
  }, []);

  const updateNote = useCallback((id: string, content: string) => {
    setNotes(prev => {
      const next = prev.map(n => n.id === id ? { ...n, content, updatedAt: new Date().toISOString() } : n);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const deleteNote = useCallback((id: string) => {
    setNotes(prev => {
      const next = prev.filter(n => n.id !== id);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const searchNotes = useCallback((query: string): SessionNote[] => {
    if (!query.trim()) return notes;
    const lower = query.toLowerCase();
    return notes.filter(n =>
      n.content.toLowerCase().includes(lower) ||
      n.tags.some(t => t.toLowerCase().includes(lower))
    );
  }, [notes]);

  const getNotesForSession = useCallback((sessionId: string): SessionNote[] => {
    return notes.filter(n => n.sessionId === sessionId);
  }, [notes]);

  const getAllTags = useCallback((): string[] => {
    const tagSet = new Set<string>();
    for (const n of notes) {
      for (const tag of n.tags) {
        tagSet.add(tag);
      }
    }
    return [...tagSet].sort();
  }, [notes]);

  return {
    notes,
    addNote,
    updateNote,
    deleteNote,
    searchNotes,
    getNotesForSession,
    getAllTags,
  };
}
