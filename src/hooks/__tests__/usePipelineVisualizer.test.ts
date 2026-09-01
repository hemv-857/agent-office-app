import { describe, it, expect, beforeEach } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { usePipelineVisualizer } from '../usePipelineVisualizer';

describe('usePipelineVisualizer', () => {
  beforeEach(() => {});

  it('starts with empty nodes', () => {
    const { result } = renderHook(() => usePipelineVisualizer());
    expect(result.current.nodes.size).toBe(0);
    expect(result.current.stages).toEqual([]);
  });

  it('initializes a pipeline', () => {
    const { result } = renderHook(() => usePipelineVisualizer());
    act(() => {
      result.current.initPipeline({
        stages: [
          { name: 'Stage 1', nodes: ['n1', 'n2'], parallel: true },
          { name: 'Stage 2', nodes: ['n3'], parallel: false },
        ],
        nodes: [
          { id: 'n1', agentId: 'a1', agentName: 'Agent 1', status: 'pending', dependencies: [] },
          { id: 'n2', agentId: 'a2', agentName: 'Agent 2', status: 'pending', dependencies: [] },
          { id: 'n3', agentId: 'a3', agentName: 'Agent 3', status: 'pending', dependencies: ['n1', 'n2'] },
        ],
      });
    });
    expect(result.current.nodes.size).toBe(3);
    expect(result.current.stages).toHaveLength(2);
  });

  it('marks node as running', () => {
    const { result } = renderHook(() => usePipelineVisualizer());
    act(() => {
      result.current.initPipeline({
        stages: [{ name: 'S1', nodes: ['n1'], parallel: false }],
        nodes: [{ id: 'n1', agentId: 'a1', agentName: 'Agent 1', status: 'pending', dependencies: [] }],
      });
    });
    act(() => {
      result.current.markRunning('n1');
    });
    expect(result.current.nodes.get('n1')?.status).toBe('running');
  });

  it('marks node as completed', () => {
    const { result } = renderHook(() => usePipelineVisualizer());
    act(() => {
      result.current.initPipeline({
        stages: [{ name: 'S1', nodes: ['n1'], parallel: false }],
        nodes: [{ id: 'n1', agentId: 'a1', agentName: 'Agent 1', status: 'pending', dependencies: [] }],
      });
    });
    act(() => {
      result.current.markCompleted('n1', 'Done!');
    });
    const node = result.current.nodes.get('n1');
    expect(node?.status).toBe('completed');
    expect(node?.result).toBe('Done!');
  });

  it('marks node as failed', () => {
    const { result } = renderHook(() => usePipelineVisualizer());
    act(() => {
      result.current.initPipeline({
        stages: [{ name: 'S1', nodes: ['n1'], parallel: false }],
        nodes: [{ id: 'n1', agentId: 'a1', agentName: 'Agent 1', status: 'pending', dependencies: [] }],
      });
    });
    act(() => {
      result.current.markFailed('n1', 'Error occurred');
    });
    const node = result.current.nodes.get('n1');
    expect(node?.status).toBe('failed');
    expect(node?.error).toBe('Error occurred');
  });

  it('calculates progress', () => {
    const { result } = renderHook(() => usePipelineVisualizer());
    act(() => {
      result.current.initPipeline({
        stages: [{ name: 'S1', nodes: ['n1', 'n2'], parallel: false }],
        nodes: [
          { id: 'n1', agentId: 'a1', agentName: 'A1', status: 'pending', dependencies: [] },
          { id: 'n2', agentId: 'a2', agentName: 'A2', status: 'pending', dependencies: [] },
        ],
      });
    });
    act(() => { result.current.markCompleted('n1', 'ok'); });
    const progress = result.current.getProgress();
    expect(progress.total).toBe(2);
    expect(progress.completed).toBe(1);
    expect(progress.percent).toBe(50);
  });

  it('gets ready nodes', () => {
    const { result } = renderHook(() => usePipelineVisualizer());
    act(() => {
      result.current.initPipeline({
        stages: [
          { name: 'S1', nodes: ['n1'], parallel: false },
          { name: 'S2', nodes: ['n2'], parallel: false },
        ],
        nodes: [
          { id: 'n1', agentId: 'a1', agentName: 'A1', status: 'pending', dependencies: [] },
          { id: 'n2', agentId: 'a2', agentName: 'A2', status: 'pending', dependencies: ['n1'] },
        ],
      });
    });
    const ready = result.current.getReadyNodes();
    expect(ready).toHaveLength(1);
    expect(ready[0].id).toBe('n1');

    act(() => { result.current.markCompleted('n1', 'done'); });
    const readyAfter = result.current.getReadyNodes();
    expect(readyAfter).toHaveLength(1);
    expect(readyAfter[0].id).toBe('n2');
  });

  it('clears pipeline', () => {
    const { result } = renderHook(() => usePipelineVisualizer());
    act(() => {
      result.current.initPipeline({
        stages: [{ name: 'S1', nodes: ['n1'], parallel: false }],
        nodes: [{ id: 'n1', agentId: 'a1', agentName: 'A1', status: 'pending', dependencies: [] }],
      });
    });
    act(() => { result.current.clearPipeline(); });
    expect(result.current.nodes.size).toBe(0);
    expect(result.current.stages).toEqual([]);
  });
});
