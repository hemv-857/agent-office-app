import { useState, useCallback } from 'react';
import { invoke } from '@tauri-apps/api/core';

export interface Subtask {
  title: string;
  description: string;
  suggested_agent_role: string;
}

export interface DecomposedTask {
  subtasks: Subtask[];
  reasoning: string;
}

interface UseTaskDecompositionProps {
  provider: string;
  showToast: (msg: string, type?: 'error' | 'success') => void;
}

export function useTaskDecomposition({ provider, showToast }: UseTaskDecompositionProps) {
  const [decomposed, setDecomposed] = useState<DecomposedTask | null>(null);
  const [decomposing, setDecomposing] = useState(false);

  const decompose = useCallback(async (prompt: string) => {
    if (!prompt.trim()) {
      showToast('Enter a prompt first', 'error');
      return;
    }
    setDecomposing(true);
    try {
      const result: DecomposedTask = await invoke('decompose_task', { prompt, provider });
      setDecomposed(result);
      showToast(`Decomposed into ${result.subtasks.length} subtasks`, 'success');
    } catch (e) {
      showToast(typeof e === 'string' ? e : 'Decomposition failed', 'error');
    } finally {
      setDecomposing(false);
    }
  }, [provider, showToast]);

  const clear = useCallback(() => setDecomposed(null), []);

  const buildSubtaskPrompt = useCallback((subtask: Subtask, previousResults: string[]): string => {
    let ctx = subtask.description;
    if (previousResults.length > 0) {
      ctx += '\n\nPrevious work:\n' + previousResults.map((r, i) => `Step ${i + 1}: ${r.slice(0, 500)}`).join('\n');
    }
    return ctx;
  }, []);

  return {
    decomposed,
    decomposing,
    decompose,
    clear,
    buildSubtaskPrompt,
  };
}
