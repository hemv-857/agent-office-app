import { describe, it, expect, beforeEach } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useSessionNotes } from '../useSessionNotes';

describe('useSessionNotes', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('starts with empty notes', () => {
    const { result } = renderHook(() => useSessionNotes());
    expect(result.current.notes).toEqual([]);
  });

  it('adds a note', () => {
    const { result } = renderHook(() => useSessionNotes());
    act(() => {
      result.current.addNote('session-1', 'Test note', ['bug', 'urgent']);
    });
    expect(result.current.notes).toHaveLength(1);
    expect(result.current.notes[0].content).toBe('Test note');
    expect(result.current.notes[0].tags).toEqual(['bug', 'urgent']);
    expect(result.current.notes[0].sessionId).toBe('session-1');
  });

  it('updates a note', () => {
    const { result } = renderHook(() => useSessionNotes());
    let noteId = '';
    act(() => {
      const note = result.current.addNote('s1', 'original');
      noteId = note.id;
    });
    act(() => {
      result.current.updateNote(noteId, 'updated content');
    });
    expect(result.current.notes[0].content).toBe('updated content');
  });

  it('deletes a note', () => {
    const { result } = renderHook(() => useSessionNotes());
    let noteId = '';
    act(() => {
      const note = result.current.addNote('s1', 'delete me');
      noteId = note.id;
    });
    expect(result.current.notes).toHaveLength(1);
    act(() => {
      result.current.deleteNote(noteId);
    });
    expect(result.current.notes).toHaveLength(0);
  });

  it('searches notes', () => {
    const { result } = renderHook(() => useSessionNotes());
    act(() => {
      result.current.addNote('s1', 'Bug in login flow');
      result.current.addNote('s1', 'Feature request');
      result.current.addNote('s1', 'Bug in payment');
    });
    const found = result.current.searchNotes('bug');
    expect(found).toHaveLength(2);
    const notFound = result.current.searchNotes('xyz');
    expect(notFound).toHaveLength(0);
  });

  it('gets notes for a session', () => {
    const { result } = renderHook(() => useSessionNotes());
    act(() => {
      result.current.addNote('s1', 'note 1');
      result.current.addNote('s1', 'note 2');
      result.current.addNote('s2', 'note 3');
    });
    expect(result.current.getNotesForSession('s1')).toHaveLength(2);
    expect(result.current.getNotesForSession('s2')).toHaveLength(1);
  });

  it('gets all tags', () => {
    const { result } = renderHook(() => useSessionNotes());
    act(() => {
      result.current.addNote('s1', 'note', ['bug', 'urgent']);
      result.current.addNote('s1', 'note', ['feature', 'bug']);
    });
    const tags = result.current.getAllTags();
    expect(tags).toContain('bug');
    expect(tags).toContain('urgent');
    expect(tags).toContain('feature');
  });
});
