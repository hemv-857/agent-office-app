import { useState } from 'react';

interface Session {
  id: string;
  prompt: string;
  agentIds: string[];
  provider: string;
  timestamp: string;
  results: unknown[];
  totalCost: number;
  totalTokens: number;
}

interface SessionHistoryProps {
  sessions: Session[];
  onDelete: (id: string) => void;
  onClear: () => void;
  onLoad: (session: Session) => void;
}

export function SessionHistory({ sessions, onDelete, onClear, onLoad }: SessionHistoryProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [search, setSearch] = useState('');

  if (!isOpen) {
    return (
      <button
        className="session-history-toggle"
        onClick={() => setIsOpen(true)}
        title="Session history"
      >
        History
      </button>
    );
  }

  const filtered = search
    ? sessions.filter(s => s.prompt.toLowerCase().includes(search.toLowerCase()))
    : sessions;

  return (
    <div className="session-history-panel">
      <div className="session-history-header">
        <h3>Sessions ({sessions.length})</h3>
        <div style={{ display: 'flex', gap: 4 }}>
          {sessions.length > 0 && (
            <button className="link-btn" onClick={onClear} style={{ fontSize: 11 }}>clear all</button>
          )}
          <button className="modal-close" onClick={() => setIsOpen(false)}>×</button>
        </div>
      </div>
      {sessions.length > 0 && (
        <input
          className="session-search"
          placeholder="Search sessions..."
          value={search}
          onChange={e => setSearch(e.target.value)}
        />
      )}
      <div className="session-list">
        {filtered.length === 0 && (
          <div className="empty-state" style={{ padding: 24 }}>
            <span className="empty-state-icon">No sessions</span>
            <p className="empty-state-desc">No sessions yet. Run agents and save results.</p>
          </div>
        )}
        {filtered.map(session => (
          <div key={session.id} className="session-item">
            <div className="session-prompt">{session.prompt.slice(0, 60)}{session.prompt.length > 60 ? '…' : ''}</div>
            <div className="session-meta">
              <span>{session.agentIds.length} agents</span>
              <span>{session.provider}</span>
              <span>${session.totalCost.toFixed(4)}</span>
              <span>{new Date(session.timestamp).toLocaleDateString()}</span>
            </div>
            <div className="session-actions">
              <button className="link-btn" onClick={() => onLoad(session)} title="Load session">load</button>
              <button className="link-btn" onClick={() => onDelete(session.id)} title="Delete" style={{ color: 'var(--red)' }}>×</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
