import React, { Suspense } from 'react';
import { Spinner } from './Spinner';

interface LazyModalProps {
  open: boolean;
  children: React.ReactNode;
}

export function LazyModal({ open, children }: LazyModalProps) {
  if (!open) return null;
  return (
    <Suspense fallback={<div className="modal-overlay"><Spinner size={32} label="Loading…" /></div>}>
      {children}
    </Suspense>
  );
}

// Pre-lazy all modals for code splitting
export const LazySettingsModal = React.lazy(() =>
  import('./Modals').then(m => ({ default: m.SettingsModal }))
);
export const LazyHelpModal = React.lazy(() =>
  import('./Modals').then(m => ({ default: m.HelpModal }))
);
export const LazyAgentDetailModal = React.lazy(() =>
  import('./Modals').then(m => ({ default: m.AgentDetailModal }))
);
export const LazyChatModal = React.lazy(() =>
  import('./Modals').then(m => ({ default: m.ChatModal }))
);
export const LazyPerformanceModal = React.lazy(() =>
  import('./Modals').then(m => ({ default: m.PerformanceModal }))
);
export const LazyCostTrackerModal = React.lazy(() =>
  import('./Modals').then(m => ({ default: m.CostTrackerModal }))
);
export const LazyLeaderboardModal = React.lazy(() =>
  import('./Modals').then(m => ({ default: m.LeaderboardModal }))
);
export const LazyMcpToolsModal = React.lazy(() =>
  import('./Modals').then(m => ({ default: m.McpToolsModal }))
);
export const LazyAgentMemoryPanel = React.lazy(() =>
  import('./Modals').then(m => ({ default: m.AgentMemoryPanel }))
);
