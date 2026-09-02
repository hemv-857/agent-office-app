import React, { useState } from 'react';
import type { SessionNote } from '../hooks/useSessionNotes';

interface SessionNotesModalProps {
  notes: SessionNote[];
  onAdd: (sessionId: string, content: string, tags: string[]) => SessionNote;
  onUpdate: (id: string, content: string) => void;
  onDelete: (id: string) => void;
  onSearch: (query: string) => SessionNote[];
  allTags: string[];
  onClose: () => void;
}

export const SessionNotesModal = React.memo(function SessionNotesModal({
  notes, onAdd, onUpdate, onDelete, onSearch, allTags, onClose,
}: SessionNotesModalProps) {
  const [search, setSearch] = useState('');
  const [newContent, setNewContent] = useState('');
  const [newTags, setNewTags] = useState('');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editContent, setEditContent] = useState('');
  const [activeTag, setActiveTag] = useState<string | null>(null);

  const displayed = (() => {
    if (activeTag) return notes.filter(n => n.tags.includes(activeTag));
    if (search) return onSearch(search);
    return notes;
  })();

  function handleAdd() {
    if (!newContent.trim()) return;
    onAdd('current', newContent.trim(), newTags.split(',').map(t => t.trim()).filter(Boolean));
    setNewContent('');
    setNewTags('');
  }

  function handleSaveEdit(id: string) {
    onUpdate(id, editContent);
    setEditingId(null);
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 600, maxHeight: '80vh', display: 'flex', flexDirection: 'column' }}>
        <h2>Session Notes</h2>
        <input
          className="prompt-input"
          placeholder="Search notes…"
          value={search}
          onChange={e => { setSearch(e.target.value); setActiveTag(null); }}
          style={{ marginBottom: 12 }}
        />
        {allTags.length > 0 && (
          <div className="filter-pills" style={{ marginBottom: 12, flexWrap: 'wrap' }}>
            <button
              className={`filter-pill ${!activeTag ? 'active' : ''}`}
              onClick={() => setActiveTag(null)}
            >All</button>
            {allTags.map(tag => (
              <button
                key={tag}
                className={`filter-pill ${activeTag === tag ? 'active' : ''}`}
                onClick={() => setActiveTag(activeTag === tag ? null : tag)}
              >{tag}</button>
            ))}
          </div>
        )}
        <div style={{ marginBottom: 12, display: 'flex', gap: 8 }}>
          <input
            className="prompt-input"
            placeholder="Note…"
            value={newContent}
            onChange={e => setNewContent(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && handleAdd()}
            style={{ flex: 1 }}
          />
          <input
            className="prompt-input"
            placeholder="Tags (comma-sep)"
            value={newTags}
            onChange={e => setNewTags(e.target.value)}
            style={{ width: 140 }}
          />
          <button className="prompt-send" onClick={handleAdd}>+</button>
        </div>
        <div style={{ flex: 1, overflowY: 'auto' }}>
          {displayed.length === 0 && <div className="empty-state">No notes yet</div>}
          {displayed.map(note => (
            <div key={note.id} className="session-note-item">
              {editingId === note.id ? (
                <div style={{ display: 'flex', gap: 8 }}>
                  <input
                    className="prompt-input"
                    value={editContent}
                    onChange={e => setEditContent(e.target.value)}
                    onKeyDown={e => e.key === 'Enter' && handleSaveEdit(note.id)}
                    autoFocus
                  />
                  <button className="prompt-send" onClick={() => handleSaveEdit(note.id)}></button>
                  <button className="prompt-send" onClick={() => setEditingId(null)}>X</button>
                </div>
              ) : (
                <>
                  <div className="session-note-content">{note.content}</div>
                  <div className="session-note-meta">
                    <span>{new Date(note.createdAt).toLocaleDateString()}</span>
                    {note.tags.length > 0 && (
                      <span className="session-note-tags">
                        {note.tags.map(t => <span key={t} className="tag-badge">{t}</span>)}
                      </span>
                    )}
                  </div>
                  <div className="session-note-actions">
                    <button onClick={() => { setEditingId(note.id); setEditContent(note.content); }}>Edit</button>
                    <button onClick={() => onDelete(note.id)} className="danger">Delete</button>
                  </div>
                </>
              )}
            </div>
          ))}
        </div>
        <button className="modal-cancel" onClick={onClose}>Close</button>
      </div>
    </div>
  );
});
