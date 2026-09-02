import React, { useMemo } from 'react';
import type { ProviderHealth } from '../hooks/useAgentHealth';

interface AgentHealthIndicatorProps {
  providers: Map<string, ProviderHealth>;
  onOpen?: () => void;
}

export const AgentHealthIndicator = React.memo(function AgentHealthIndicator({ providers, onOpen }: AgentHealthIndicatorProps) {
  const summary = useMemo(() => {
    const all = Array.from(providers.values());
    if (all.length === 0) return { label: 'No providers', dot: '' };
    const down = all.find(p => p.status === 'down');
    const degraded = all.find(p => p.status === 'degraded');
    if (down) return { label: `${down.provider} down`, dot: '' };
    if (degraded) return { label: `${degraded.provider} degraded`, dot: '🟡' };
    return { label: 'All healthy', dot: 'OK' };
  }, [providers]);

  return (
    <button
      className="health-indicator"
      onClick={onOpen}
      title="Provider health"
      aria-label={`Provider health: ${summary.label}`}
    >
      <span className="health-dot">{summary.dot}</span>
      <span className="health-label">{summary.label}</span>
    </button>
  );
});
