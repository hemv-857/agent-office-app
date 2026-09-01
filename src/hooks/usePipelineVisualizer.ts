import { useState, useCallback } from 'react';

export interface PipelineNode {
  id: string;
  agentId: string;
  agentName: string;
  status: 'pending' | 'running' | 'completed' | 'failed' | 'skipped';
  dependencies: string[];
  result?: string;
  startedAt?: string;
  completedAt?: string;
  error?: string;
}

export interface PipelineStage {
  name: string;
  nodes: string[];
  parallel: boolean;
}

export function usePipelineVisualizer() {
  const [nodes, setNodes] = useState<Map<string, PipelineNode>>(new Map());
  const [stages, setStages] = useState<PipelineStage[]>([]);

  const initPipeline = useCallback((pipeline: { stages: PipelineStage[]; nodes: PipelineNode[] }) => {
    const nodeMap = new Map<string, PipelineNode>();
    for (const n of pipeline.nodes) {
      nodeMap.set(n.id, n);
    }
    setNodes(nodeMap);
    setStages(pipeline.stages);
  }, []);

  const updateNode = useCallback((id: string, updates: Partial<PipelineNode>) => {
    setNodes(prev => {
      const next = new Map(prev);
      const node = next.get(id);
      if (node) {
        next.set(id, { ...node, ...updates });
      }
      return next;
    });
  }, []);

  const markRunning = useCallback((id: string) => {
    updateNode(id, { status: 'running', startedAt: new Date().toISOString() });
  }, [updateNode]);

  const markCompleted = useCallback((id: string, result: string) => {
    updateNode(id, { status: 'completed', result, completedAt: new Date().toISOString() });
  }, [updateNode]);

  const markFailed = useCallback((id: string, error: string) => {
    updateNode(id, { status: 'failed', error, completedAt: new Date().toISOString() });
  }, [updateNode]);

  const getProgress = useCallback(() => {
    const allNodes = Array.from(nodes.values());
    const total = allNodes.length;
    const completed = allNodes.filter(n => n.status === 'completed').length;
    const failed = allNodes.filter(n => n.status === 'failed').length;
    const running = allNodes.filter(n => n.status === 'running').length;
    return { total, completed, failed, running, percent: total > 0 ? (completed / total) * 100 : 0 };
  }, [nodes]);

  const getReadyNodes = useCallback((): PipelineNode[] => {
    return Array.from(nodes.values()).filter(node => {
      if (node.status !== 'pending') return false;
      return node.dependencies.every(depId => {
        const dep = nodes.get(depId);
        return dep?.status === 'completed' || dep?.status === 'skipped';
      });
    });
  }, [nodes]);

  const clearPipeline = useCallback(() => {
    setNodes(new Map());
    setStages([]);
  }, []);

  return {
    nodes,
    stages,
    initPipeline,
    updateNode,
    markRunning,
    markCompleted,
    markFailed,
    getProgress,
    getReadyNodes,
    clearPipeline,
  };
}
