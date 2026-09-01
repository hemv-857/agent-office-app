import { useState, useRef, useCallback } from 'react';
import { invoke } from '@tauri-apps/api/core';

export interface OvernightState {
  running: boolean;
  iteration: number;
  maxIterations: number;
  totalTokens: number;
  maxTokens: number;
  totalCost: number;
  commits: number;
  rollbacks: number;
  startTime: number | null;
  objective: string;
  branch: string;
  preventSleep: boolean;
  sleepPid: number | null;
  lastError: string | null;
}

export interface OvernightSummary {
  iterations: number;
  totalTokens: number;
  totalCost: number;
  commits: number;
  rollbacks: number;
  elapsedMs: number;
  branch: string;
}

export function useOvernight() {
  const [state, setState] = useState<OvernightState>({
    running: false,
    iteration: 0,
    maxIterations: 10,
    totalTokens: 0,
    maxTokens: 1_000_000,
    totalCost: 0,
    commits: 0,
    rollbacks: 0,
    startTime: null,
    objective: '',
    branch: '',
    preventSleep: true,
    sleepPid: null,
    lastError: null,
  });

  const [summary, setSummary] = useState<OvernightSummary | null>(null);
  const abortRef = useRef(false);

  const startOvernight = useCallback(async (
    objective: string,
    maxIterations: number,
    maxTokens: number,
    provider: string,
    preventSleep: boolean,
    executeTask: (prompt: string, agentIds: string[]) => Promise<void>,
    getSeatedAgentIds: () => string[],
  ) => {
    abortRef.current = false;
    const startTime = Date.now();
    let branch = '';
    let sleepPid = 0;

    // Create overnight branch
    try {
      branch = await invoke<string>('get_git_branch');
      const branchName = `overnight/${objective.slice(0, 40).replace(/[^a-z0-9]/gi, '-').replace(/-+/g, '-')}`;
      try {
        await invoke('create_branch', { name: branchName });
        branch = branchName;
      } catch {
        // Branch might exist, continue on current
      }
    } catch {
      // Not a git repo, continue without git
    }

    // Start sleep prevention
    if (preventSleep) {
      try {
        sleepPid = await invoke<number>('start_sleep_prevent');
      } catch {
        // Sleep prevention unavailable
      }
    }

    setState(s => ({
      ...s,
      running: true,
      iteration: 0,
      maxIterations,
      totalTokens: 0,
      maxTokens,
      totalCost: 0,
      commits: 0,
      rollbacks: 0,
      startTime,
      objective,
      branch,
      preventSleep,
      sleepPid,
      lastError: null,
    }));

    let iteration = 0;
    let commits = 0;
    let rollbacks = 0;
    let lastError: string | null = null;

    while (iteration < maxIterations && !abortRef.current) {
      iteration++;

      // Check token budget (tracked via store, check here for hard cap)
      // Token budget is checked on the frontend store side

      const agentIds = getSeatedAgentIds();
      if (agentIds.length === 0) {
        lastError = 'No agents seated';
        break;
      }

      try {
        // Run agents
        await executeTask(objective, agentIds);

        // Small delay to let streaming finish
        await new Promise(r => setTimeout(r, 1000));

        // Commit results
        try {
          const hash = await invoke<string>('commit_batch', {
            message: `overnight #${iteration}: ${objective.slice(0, 60)}`,
          });
          if (hash !== 'nothing to commit') {
            commits++;
          }
        } catch (e) {
          // Commit failed — rollback
          try {
            await invoke('rollback_batch');
            rollbacks++;
          } catch {
            // Rollback also failed
          }
          lastError = `Commit failed: ${typeof e === 'string' ? e : 'unknown'}`;
        }

        setState(s => ({
          ...s,
          iteration,
          commits,
          rollbacks,
          lastError,
        }));
      } catch (e) {
        lastError = typeof e === 'string' ? e : 'Iteration failed';
        rollbacks++;
        try {
          await invoke('rollback_batch');
        } catch {
          // Rollback failed
        }

        setState(s => ({
          ...s,
          iteration,
          commits,
          rollbacks,
          lastError,
        }));
      }
    }

    // Stop sleep prevention
    if (sleepPid) {
      try {
        await invoke('stop_sleep_prevent', { pid: sleepPid });
      } catch {
        // Ignore
      }
    }

    const elapsedMs = Date.now() - startTime;
    const finalSummary: OvernightSummary = {
      iterations: iteration,
      totalTokens: 0,
      totalCost: 0,
      commits,
      rollbacks,
      elapsedMs,
      branch,
    };

    setSummary(finalSummary);
    setState(s => ({
      ...s,
      running: false,
      sleepPid: null,
    }));
  }, []);

  const stopOvernight = useCallback(() => {
    abortRef.current = true;
  }, []);

  const clearSummary = useCallback(() => {
    setSummary(null);
  }, []);

  return {
    state,
    summary,
    startOvernight,
    stopOvernight,
    clearSummary,
  };
}
