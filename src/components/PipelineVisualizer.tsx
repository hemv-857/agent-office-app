import React, { useMemo } from 'react';
import type { PipelineNode } from '../hooks/usePipelineVisualizer';

interface PipelineVisualizerProps {
  nodes: Map<string, PipelineNode>;
  stages: { name: string; nodes: string[]; parallel: boolean }[];
}

function statusColor(status: PipelineNode['status']): string {
  switch (status) {
    case 'completed': return '#22c55e';
    case 'running': return '#3b82f6';
    case 'failed': return '#ef4444';
    case 'skipped': return '#71717a';
    default: return '#3f3f46';
  }
}

function statusIcon(status: PipelineNode['status']): string {
  switch (status) {
    case 'completed': return '✓';
    case 'running': return '●';
    case 'failed': return 'X';
    case 'skipped': return '○';
    default: return '◌';
  }
}

export const PipelineVisualizer = React.memo(function PipelineVisualizer({ nodes, stages }: PipelineVisualizerProps) {
  const progress = useMemo(() => {
    const all = Array.from(nodes.values());
    const total = all.length;
    const completed = all.filter(n => n.status === 'completed').length;
    return total > 0 ? (completed / total) * 100 : 0;
  }, [nodes]);

  if (stages.length === 0) return null;

  return (
    <div className="pipeline-visualizer" role="region" aria-label="Pipeline progress">
      <div className="pipeline-progress-bar">
        <div className="pipeline-progress-fill" style={{ width: `${progress}%` }} />
        <span className="pipeline-progress-text">{Math.round(progress)}%</span>
      </div>
      <div className="pipeline-stages">
        {stages.map((stage, si) => (
          <div key={si} className="pipeline-stage">
            <div className="pipeline-stage-header">
              <span className="pipeline-stage-name">{stage.name}</span>
              {stage.parallel && <span className="pipeline-stage-badge">parallel</span>}
            </div>
            <div className="pipeline-stage-nodes">
              {stage.nodes.map(nodeId => {
                const node = nodes.get(nodeId);
                if (!node) return null;
                return (
                  <div key={nodeId} className="pipeline-node" title={node.error || node.agentName}>
                    <span
                      className="pipeline-node-dot"
                      style={{ background: statusColor(node.status) }}
                    />
                    <span className="pipeline-node-label">{node.agentName}</span>
                    <span className="pipeline-node-status">{statusIcon(node.status)}</span>
                  </div>
                );
              })}
            </div>
            {si < stages.length - 1 && <div className="pipeline-arrow">→</div>}
          </div>
        ))}
      </div>
    </div>
  );
});
