import React, { useState, useMemo } from 'react';
import type { ActivityEntry } from '../types';

interface ActivityLogProps {
  entries: ActivityEntry[];
  onClear: () => void;
}

export const ActivityLog = React.memo(function ActivityLog({ entries, onClear }: ActivityLogProps) {
  const [filter, setFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState<string | null>(null);

  const displayed = useMemo(() => {
    return entries.filter(e => {
      if (typeFilter && e.type !== typeFilter) return false;
      if (filter && !e.message.toLowerCase().includes(filter.toLowerCase())) return false;
      return true;
    });
  }, [entries, filter, typeFilter]);

  if (entries.length === 0) return null;

  const typeIcon: Record<string, string> = {
    info: 'ℹ',
    success: '✓',
    warning: '⚠',
    error: '✕',
  };

  return (
    <div className="activity-log" role="log" aria-label="Activity log">
      <div className="activity-header">
        <span className="activity-title">Activity ({displayed.length})</span>
        <input
          className="activity-search"
          placeholder="Filter…"
          value={filter}
          onChange={e => setFilter(e.target.value)}
          aria-label="Filter activity log"
        />
        <div className="activity-type-filters">
          {['info', 'success', 'warning', 'error'].map(t => (
            <button
              key={t}
              className={`activity-type-btn ${typeFilter === t ? 'active' : ''}`}
              onClick={() => setTypeFilter(typeFilter === t ? null : t)}
            >
              {typeIcon[t]}
            </button>
          ))}
        </div>
        <button className="activity-clear" onClick={onClear} title="Clear log">Clear</button>
      </div>
      <div className="activity-entries">
        {displayed.length === 0 && <div className="empty-state">No matching entries</div>}
        {displayed.slice(0, 30).map(e => (
          <div key={e.id} className={`activity-entry ${e.type}`}>
            <span className="activity-icon">{typeIcon[e.type]}</span>
            <span className="activity-message">{e.message}</span>
            <span className="activity-time">{new Date(e.timestamp).toLocaleTimeString()}</span>
          </div>
        ))}
      </div>
    </div>
  );
});
