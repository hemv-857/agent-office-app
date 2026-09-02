import React from 'react';
import type { OfficeAgent } from '../types';
import { ROLES } from '../utils/constants';

interface OfficeGridProps {
  officeAgents: OfficeAgent[];
  compactOffice: boolean;
  dragOverRole: string | null;
  onDragOver: (e: React.DragEvent, role: string) => void;
  onDragLeave: () => void;
  onDrop: (e: React.DragEvent, role: string) => void;
  onDeskDragStart: (e: React.DragEvent, role: string) => void;
  onDeskDrop: (e: React.DragEvent, role: string) => void;
  onRemoveFromDesk: (role: string) => void;
}

export const OfficeGrid = React.memo(function OfficeGrid({
  officeAgents,
  compactOffice,
  dragOverRole,
  onDragOver,
  onDragLeave,
  onDrop,
  onDeskDragStart,
  onDeskDrop,
  onRemoveFromDesk,
}: OfficeGridProps) {
  return (
    <div className={`office-section ${compactOffice ? 'compact' : ''}`} role="region" aria-label="Office grid">
      <div className="office-grid" role="listbox" aria-label="Agent desks">
        {ROLES.map(role => {
          const agent = officeAgents.find(a => a.role === role);
          const isDropTarget = dragOverRole === role;
          return (
            <div
              key={role}
              className={`desk ${agent ? 'occupied' : ''} ${isDropTarget ? 'drag-over' : ''}`}
              draggable={!!agent}
              onDragStart={agent ? e => onDeskDragStart(e, role) : undefined}
              onDragOver={e => onDragOver(e, role)}
              onDragLeave={onDragLeave}
              onDrop={e => { onDrop(e, role); onDeskDrop(e, role); }}
              onClick={() => agent && onRemoveFromDesk(role)}
              title={agent ? `Click to remove ${agent.name}. Drag to swap.` : `Drop an agent here (${role})`}
              role="option"
              aria-label={agent ? `${agent.name} at ${role} desk, status ${agent.status}` : `Empty ${role} desk`}
              aria-selected={!!agent}
            >
              {agent ? (
                <>
                  <div className="desk-label">{role}</div>
                  <div className="desk-agent">{agent.name.split(' ')[0]}</div>
                  <div className="desk-name">{agent.name.split(' ').slice(1).join(' ')}</div>
                  <div className={`desk-status ${agent.status}`}>{agent.status}</div>
                </>
              ) : (
                <>
                  <div className="desk-label">{role}</div>
                  <div className="desk-agent" style={{ opacity: 0.2 }}>+</div>
                </>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
});
