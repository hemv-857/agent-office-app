import React from 'react';

interface DevOverlayProps {
  info: {
    renderCount: number;
    lastRenderTime: number;
    memoryUsage: number;
    localStorageSize: number;
  };
  onToggle: () => void;
}

export const DevOverlay = React.memo(function DevOverlay({ info, onToggle }: DevOverlayProps) {
  const formatBytes = (bytes: number) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  };

  return (
    <div
      style={{
        position: 'fixed',
        bottom: 40,
        right: 8,
        background: 'rgba(0, 0, 0, 0.85)',
        color: '#34d399',
        fontFamily: 'monospace',
        fontSize: 10,
        padding: '6px 10px',
        borderRadius: 6,
        zIndex: 9999,
        lineHeight: 1.5,
        minWidth: 160,
        border: '1px solid rgba(52, 211, 153, 0.3)',
      }}
      role="status"
      aria-label="Developer tools overlay"
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
        <span style={{ fontWeight: 600 }}>DEV MODE</span>
        <button
          onClick={onToggle}
          style={{
            background: 'none',
            border: 'none',
            color: '#71717a',
            cursor: 'pointer',
            padding: 0,
            fontSize: 10,
          }}
        >×</button>
      </div>
      <div>Renders: {info.renderCount}</div>
      <div>Memory: {formatBytes(info.memoryUsage)}</div>
      <div>Storage: {formatBytes(info.localStorageSize)}</div>
      <div>Time: {info.lastRenderTime.toFixed(0)}ms</div>
    </div>
  );
});
