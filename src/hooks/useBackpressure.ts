import { useState, useCallback } from 'react';
import { invoke } from '@tauri-apps/api/core';

export interface GateResult {
  agentId: string;
  passed: boolean;
  score: number;
  reasoning: string;
}

interface UseBackpressureProps {
  provider: string;
  showToast: (msg: string, type?: 'error' | 'success') => void;
}

export function useBackpressure({ provider, showToast }: UseBackpressureProps) {
  const [gateResults, setGateResults] = useState<GateResult[]>([]);
  const [checking, setChecking] = useState(false);

  const checkGate = useCallback(async (
    response: string,
    criteria: string,
    agentId: string,
  ): Promise<GateResult> => {
    try {
      const result: { passed: boolean; score: number; reasoning: string } = await invoke('evaluate_quality', {
        response,
        criteria,
        provider,
      });
      const gateResult: GateResult = { agentId, ...result };
      setGateResults(prev => [...prev, gateResult]);
      return gateResult;
    } catch {
      const fallback: GateResult = { agentId, passed: true, score: 0.5, reasoning: 'Gate check unavailable' };
      setGateResults(prev => [...prev, fallback]);
      return fallback;
    }
  }, [provider]);

  const checkAllGates = useCallback(async (
    responses: { agentId: string; text: string }[],
    criteria: string,
  ): Promise<boolean> => {
    setChecking(true);
    setGateResults([]);
    try {
      const results = await Promise.all(
        responses.map(r => checkGate(r.text, criteria, r.agentId))
      );
      const allPassed = results.every(r => r.passed);
      if (!allPassed) {
        showToast(`Quality gate failed: ${results.filter(r => !r.passed).length} agent(s) below threshold`, 'error');
      }
      return allPassed;
    } finally {
      setChecking(false);
    }
  }, [checkGate, showToast]);

  const clearResults = useCallback(() => setGateResults([]), []);

  return {
    gateResults,
    checking,
    checkGate,
    checkAllGates,
    clearResults,
  };
}
