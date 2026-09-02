import React from 'react';

interface StatusBarProps {
  agentCount: number;
  seatedCount: number;
  provider: string;
  totalCost: number;
  totalTokens: number;
  isRunning: boolean;
  activityCount: number;
  onClearActivity: () => void;
}

export const StatusBar = React.memo(function StatusBar({
  agentCount,
  seatedCount,
  provider,
  totalCost,
  totalTokens,
  isRunning,
  activityCount,
  onClearActivity,
}: StatusBarProps) {
  return (
    <div className="status-bar" role="status" aria-live="polite">
      <span>{agentCount} agents</span>
      <span className="status-sep">·</span>
      <span>{seatedCount}/8 seated</span>
      <span className="status-sep">·</span>
      <span>{provider}</span>
      {totalCost > 0 && (
        <>
          <span className="status-sep">·</span>
          <span>${totalCost.toFixed(4)} · {totalTokens.toLocaleString()} tokens</span>
        </>
      )}
      {isRunning && (
        <>
          <span className="status-sep">·</span>
          <span className="status-running"><span className="spinner-tiny" /> running</span>
        </>
      )}
      <span className="status-right">
        {activityCount > 0 && (
          <span className="activity-count" onClick={onClearActivity} title="Clear log">{activityCount} events</span>
        )}
        Agent Office v1.0
      </span>
    </div>
  );
});
