import { useState } from 'react';
import { invoke } from '@tauri-apps/api/core';
import type { Agent, OfficeAgent } from '../types';

export type WorkflowMode = 'parallel' | 'pipeline' | 'synthesis' | 'review' | 'debate' | 'quality-gate' | 'pipeline-approval' | 'conditional' | 'collab' | 'builder';

const WORKFLOW_MODES: { mode: WorkflowMode; label: string; icon: string; desc: string }[] = [
  { mode: 'parallel', label: 'Parallel', icon: '⚡', desc: 'All agents work simultaneously' },
  { mode: 'pipeline', label: 'Pipeline', icon: '⛓', desc: 'Each agent feeds into the next' },
  { mode: 'synthesis', label: 'Synthesis', icon: '🧠', desc: 'Parallel then synthesize consensus' },
  { mode: 'review', label: 'Review', icon: '🔍', desc: 'Parallel then cross-review each other' },
  { mode: 'debate', label: 'Debate', icon: '⚔', desc: 'State positions then critique' },
  { mode: 'quality-gate', label: 'Quality Gate', icon: '🛡', desc: 'Run then filter by quality score' },
  { mode: 'pipeline-approval', label: 'Pipeline + Approve', icon: '✋', desc: 'Pipeline with human approval between steps' },
  { mode: 'conditional', label: 'Conditional', icon: '🔀', desc: 'Route to different agents based on prompt' },
  { mode: 'collab', label: 'Collaborate', icon: '🤝', desc: 'Agents build on each other\'s work iteratively' },
  { mode: 'builder', label: 'Build Project', icon: '🚀', desc: 'Generate a complete project from a prompt' },
];

interface UseWorkflowsProps {
  provider: string;
  showToast: (msg: string, type?: 'error' | 'success') => void;
}

export function useWorkflows({ provider, showToast: _showToast }: UseWorkflowsProps) {
  const [workflowMode, setWorkflowMode] = useState<WorkflowMode>('parallel');
  const [workflowRunning, setWorkflowRunning] = useState(false);
  const [approvalStep, setApprovalStep] = useState<{ agentId: string; agentName: string; context: string } | null>(null);
  const [approvalResolve, setApprovalResolve] = useState<((approved: boolean) => void) | null>(null);

  function requestApproval(agentId: string, agentName: string, context: string): Promise<boolean> {
    return new Promise(resolve => {
      setApprovalStep({ agentId, agentName, context });
      setApprovalResolve(() => resolve);
    });
  }

  function resolveApproval(approved: boolean) {
    approvalResolve?.(approved);
    setApprovalStep(null);
    setApprovalResolve(null);
  }

  async function runWorkflow(
    prompt: string,
    selectedAgentIds: string[],
    _allAgents: Agent[],
    _setOfficeAgents: React.Dispatch<React.SetStateAction<OfficeAgent[]>>,
    _emitStreamEvent: (event: unknown) => void,
  ): Promise<void> {
    if (selectedAgentIds.length === 0) return;

    setWorkflowRunning(true);

    try {
      switch (workflowMode) {
        case 'parallel':
          await invoke<string>('execute_task', {
            request: {
              agent_ids: selectedAgentIds,
              prompt,
              provider,
              model: null,
              temperature: 0.7,
            },
          });
          break;
        case 'pipeline':
          await invoke<string>('execute_pipeline', {
            agent_ids: selectedAgentIds,
            prompt,
            provider,
          });
          break;
        case 'pipeline-approval': {
          // Sequential with approval between steps — each agent sees accumulated prompt
          const ctx = { text: prompt };
          for (const agentId of selectedAgentIds) {
            const agent = _allAgents.find(a => a.id === agentId);
            const agentName = agent?.name || agentId;
            const approved = await requestApproval(agentId, agentName, ctx.text);
            if (!approved) break;
            await invoke<string>('execute_task', {
              request: {
                agent_ids: [agentId],
                prompt: ctx.text,
                provider,
                model: null,
                temperature: 0.7,
              },
            });
          }
          break;
        }
        case 'quality-gate': {
          // Run all, then evaluate each result
          await invoke<string>('execute_task', {
            request: {
              agent_ids: selectedAgentIds,
              prompt,
              provider,
              model: null,
              temperature: 0.7,
            },
          });
          // Quality evaluation happens in the results panel via evaluate_quality
          break;
        }
        case 'synthesis': {
          await invoke<string>('execute_task', {
            request: {
              agent_ids: selectedAgentIds,
              prompt,
              provider,
              model: null,
              temperature: 0.7,
            },
          });
          break;
        }
        case 'review': {
          await invoke<string>('execute_task', {
            request: {
              agent_ids: selectedAgentIds,
              prompt,
              provider,
              model: null,
              temperature: 0.7,
            },
          });
          break;
        }
        case 'debate': {
          await invoke<string>('execute_task', {
            request: {
              agent_ids: selectedAgentIds,
              prompt: `${prompt}\n\nState your position on this topic. Be specific and provide reasoning.`,
              provider,
              model: null,
              temperature: 0.7,
            },
          });
          break;
        }
        case 'conditional': {
          // Use head agent to pick best subset, then run only those
          const result: { agent_ids: string[] } = await invoke('analyze_prompt', {
            prompt,
            provider,
          });
          if (result.agent_ids.length > 0) {
            await invoke<string>('execute_task', {
              request: {
                agent_ids: result.agent_ids,
                prompt,
                provider,
                model: null,
                temperature: 0.7,
              },
            });
          }
          break;
        }
        case 'collab': {
          // Round 1: all agents work in parallel
          await invoke<string>('execute_task', {
            request: {
              agent_ids: selectedAgentIds,
              prompt,
              provider,
              model: null,
              temperature: 0.7,
            },
          });
          // Round 2: each agent reviews and builds on others' work
          const collabPrompt = `${prompt}\n\nReview the other agents' responses above and build upon them. Identify gaps, suggest improvements, and provide your unique perspective.`;
          await invoke<string>('execute_task', {
            request: {
              agent_ids: selectedAgentIds,
              prompt: collabPrompt,
              provider,
              model: null,
              temperature: 0.7,
            },
          });
          break;
        }
      }
    } finally {
      setWorkflowRunning(false);
    }
  }

  return {
    workflowMode,
    setWorkflowMode,
    workflowRunning,
    runWorkflow,
    workflowModes: WORKFLOW_MODES,
    approvalStep,
    resolveApproval,
  };
}
