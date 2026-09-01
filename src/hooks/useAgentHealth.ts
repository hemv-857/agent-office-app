import { useState, useCallback } from 'react';

export interface ProviderHealth {
  provider: string;
  status: 'healthy' | 'degraded' | 'down';
  latencyMs: number;
  lastCheck: string;
  errorRate: number;
  rateLimitRemaining?: number;
  rateLimitReset?: string;
}

export interface RetryEntry {
  timestamp: string;
  error: string;
  attemptCount: number;
}

export function useAgentHealth() {
  const [providers, setProviders] = useState<Map<string, ProviderHealth>>(new Map());
  const [retries, setRetries] = useState<Map<string, RetryEntry[]>>(new Map());

  const updateProviderHealth = useCallback((provider: string, health: Partial<ProviderHealth>) => {
    setProviders(prev => {
      const next = new Map(prev);
      const existing = next.get(provider) || { provider, status: 'healthy' as const, latencyMs: 0, lastCheck: '', errorRate: 0 };
      next.set(provider, { ...existing, ...health, lastCheck: new Date().toISOString() });
      return next;
    });
  }, []);

  const recordRetry = useCallback((provider: string, error: string, attemptCount: number) => {
    setRetries(prev => {
      const next = new Map(prev);
      const existing = next.get(provider) || [];
      const entry: RetryEntry = { timestamp: new Date().toISOString(), error, attemptCount };
      next.set(provider, [...existing, entry].slice(-50));
      return next;
    });

    // Update error rate
    setProviders(prev => {
      const next = new Map(prev);
      const existing = next.get(provider);
      if (existing) {
        const recent = retries.get(provider)?.filter(r =>
          Date.now() - new Date(r.timestamp).getTime() < 300_000
        ) || [];
        next.set(provider, { ...existing, errorRate: recent.length / Math.max(recent.length + 10, 1) });
      }
      return next;
    });
  }, [retries]);

  const getProviderStatus = useCallback((provider: string): ProviderHealth | undefined => {
    return providers.get(provider);
  }, [providers]);

  const getRecentRetries = useCallback((provider: string): RetryEntry[] => {
    return retries.get(provider) || [];
  }, [retries]);

  const isHealthy = useCallback((provider: string): boolean => {
    const health = providers.get(provider);
    return health ? health.status === 'healthy' : true;
  }, [providers]);

  const clearHealthData = useCallback(() => {
    setProviders(new Map());
    setRetries(new Map());
  }, []);

  return {
    providers,
    retries,
    updateProviderHealth,
    recordRetry,
    getProviderStatus,
    getRecentRetries,
    isHealthy,
    clearHealthData,
  };
}
