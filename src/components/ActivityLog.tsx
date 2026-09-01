import type { ActivityEntry } from '../types';

interface ActivityLogProps {
  entries: ActivityEntry[];
}

export function ActivityLog({ entries }: ActivityLogProps) {
  if (entries.length === 0) return null;

  return (
    <div className="activity-log">
      {entries.map((entry) => (
        <div key={entry.id} className={`activity-entry ${entry.type}`}>
          <span className="activity-time">
            {new Date(entry.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </span>
          <span className="activity-text">{entry.message}</span>
        </div>
      ))}
    </div>
  );
}
