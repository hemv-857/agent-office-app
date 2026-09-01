import { describe, it, expect } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useAgentHealth } from '../useAgentHealth';

describe('useAgentHealth', () => {
  it('starts with empty providers', () => {
    const { result } = renderHook(() => useAgentHealth());
    expect(result.current.providers.size).toBe(0);
  });

  it('updates provider health', () => {
    const { result } = renderHook(() => useAgentHealth());
    act(() => {
      result.current.updateProviderHealth('anthropic', { status: 'healthy', latencyMs: 120 });
    });
    const health = result.current.getProviderStatus('anthropic');
    expect(health).toBeDefined();
    expect(health?.status).toBe('healthy');
    expect(health?.latencyMs).toBe(120);
  });

  it('records retries', () => {
    const { result } = renderHook(() => useAgentHealth());
    act(() => {
      result.current.recordRetry('openai', 'rate limited', 3);
    });
    const retries = result.current.getRecentRetries('openai');
    expect(retries).toHaveLength(1);
    expect(retries[0].error).toBe('rate limited');
    expect(retries[0].attemptCount).toBe(3);
  });

  it('checks if provider is healthy', () => {
    const { result } = renderHook(() => useAgentHealth());
    expect(result.current.isHealthy('anthropic')).toBe(true);
    act(() => {
      result.current.updateProviderHealth('anthropic', { status: 'down' });
    });
    expect(result.current.isHealthy('anthropic')).toBe(false);
  });

  it('clears health data', () => {
    const { result } = renderHook(() => useAgentHealth());
    act(() => {
      result.current.updateProviderHealth('anthropic', { status: 'healthy' });
      result.current.recordRetry('anthropic', 'error', 1);
    });
    act(() => {
      result.current.clearHealthData();
    });
    expect(result.current.providers.size).toBe(0);
    expect(result.current.getRecentRetries('anthropic')).toHaveLength(0);
  });
});
