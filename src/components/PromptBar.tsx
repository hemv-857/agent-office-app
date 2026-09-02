import React from 'react';
import type { Agent, Suggestion } from '../types';
import type { WorkflowMode } from '../hooks/useWorkflows';
import type { Subtask } from '../hooks/useTaskDecomposition';
import { TEMPLATES, WORKFLOW_TEMPLATES } from '../utils/constants';

const WORKFLOW_MODES: { mode: WorkflowMode; label: string; icon: string; desc: string }[] = [
  { mode: 'parallel', label: 'Parallel', icon: '||', desc: 'All agents work simultaneously' },
  { mode: 'pipeline', label: 'Pipeline', icon: '->', desc: 'Each agent feeds into the next' },
  { mode: 'synthesis', label: 'Synthesis', icon: '+', desc: 'Parallel then synthesize consensus' },
  { mode: 'review', label: 'Review', icon: '?', desc: 'Parallel then cross-review each other' },
  { mode: 'debate', label: 'Debate', icon: 'vs', desc: 'State positions then critique' },
  { mode: 'quality-gate', label: 'Quality Gate', icon: '!', desc: 'Run then filter by quality score' },
  { mode: 'pipeline-approval', label: 'Pipeline + Approve', icon: '*', desc: 'Pipeline with human approval' },
  { mode: 'conditional', label: 'Conditional', icon: '/', desc: 'Route based on prompt' },
];

interface PromptBarProps {
  prompt: string;
  setPrompt: (v: string) => void;
  selectedAgents: string[];
  isRunning: boolean;
  suggesting: boolean;
  suggestions: Suggestion | null;
  workflowMode: WorkflowMode;
  promptHistory: string[];
  promptQueue: string[];
  allAgents: Agent[];
  decomposed: { subtasks: Subtask[]; reasoning: string } | null;
  decomposing: boolean;
  voiceSupported: boolean;
  voiceListening: boolean;
  onSetSuggestions: (s: Suggestion | null) => void;
  onSetSelectedAgents: (ids: string[]) => void;
  onSubmit: () => void;
  onSuggest: () => void;
  onDecompose: () => void;
  onSetWorkflowMode: (mode: WorkflowMode) => void;
  onAddToQueue: () => void;
  onClearQueue: () => void;
  onRunQueue: () => void;
  onVoiceToggle: () => void;
  onWorkflowTemplate: (templateId: string) => void;
  onKeyDown: (e: React.KeyboardEvent) => void;
}

export function PromptBar({
  prompt,
  setPrompt,
  selectedAgents,
  isRunning,
  suggesting,
  suggestions,
  workflowMode,
  promptHistory,
  promptQueue,
  allAgents,
  decomposed,
  decomposing,
  voiceSupported,
  voiceListening,
  onSetSuggestions,
  onSetSelectedAgents,
  onSubmit,
  onSuggest,
  onDecompose,
  onSetWorkflowMode,
  onAddToQueue,
  onClearQueue,
  onRunQueue,
  onVoiceToggle,
  onWorkflowTemplate,
  onKeyDown,
}: PromptBarProps) {
  function autoResize(e: React.ChangeEvent<HTMLTextAreaElement>) {
    const el = e.target;
    el.style.height = 'auto';
    el.style.height = Math.min(el.scrollHeight, 120) + 'px';
  }

  return (
    <div className="prompt-section" role="region" aria-label="Prompt input">
      {promptQueue.length > 0 && (
        <div className="queue-bar">
          <span className="queue-label">Queue ({promptQueue.length})</span>
          <div className="queue-items">
            {promptQueue.map((q, i) => (
              <span key={i} className="queue-item">
                {q.length > 30 ? q.slice(0, 30) + '…' : q}
                <button className="queue-remove" onClick={() => {
                  // remove from queue handled by parent
                }}>×</button>
              </span>
            ))}
          </div>
          <button className="link-btn" onClick={onClearQueue}>clear</button>
          <button className="link-btn" onClick={onRunQueue} disabled={isRunning}>{isRunning ? '...' : '>'} run all</button>
        </div>
      )}
      {decomposed && (
        <div className="suggestions-bar">
          <span className="suggestions-label">Decomposed:</span>
          <span className="suggestions-reasoning">{decomposed.reasoning}</span>
          <div className="suggestions-tags">
            {decomposed.subtasks.map((st, i) => (
              <span key={i} className="suggestion-tag" title={st.description}>
                {st.title} <small>({st.suggested_agent_role})</small>
              </span>
            ))}
          </div>
        </div>
      )}
      {suggestions && (
        <div className="suggestions-bar">
          <span className="suggestions-label">Suggested:</span>
          <span className="suggestions-reasoning">{suggestions.reasoning}</span>
          <div className="suggestions-tags">
            {suggestions.agentIds.map(id => {
              const agent = allAgents.find(a => a.id === id);
              return agent ? <span key={id} className="suggestion-tag">{agent.emoji} {agent.name.split(' ')[0]}</span> : null;
            })}
          </div>
          <button className="link-btn" onClick={() => { onSetSuggestions(null); onSetSelectedAgents([]); }}>dismiss</button>
        </div>
      )}
      <div className="prompt-row">
        {promptHistory.length > 0 && (
          <select className="history-select" value="" onChange={e => { if (e.target.value) setPrompt(e.target.value); }}>
            <option value="" disabled>history</option>
            {promptHistory.map((p, i) => (
              <option key={i} value={p}>{p.length > 40 ? p.slice(0, 40) + '…' : p}</option>
            ))}
          </select>
        )}
        <select className="history-select" value="" onChange={e => { if (e.target.value) setPrompt(e.target.value); }}>
          <option value="" disabled>templates</option>
          {TEMPLATES.map((t, i) => (
            <option key={i} value={t.prompt}>{t.label}</option>
          ))}
        </select>
        <select className="history-select" value="" onChange={e => { if (e.target.value) onWorkflowTemplate(e.target.value); }} title="Workflow templates">
          <option value="" disabled>workflows</option>
          {WORKFLOW_TEMPLATES.map(t => (
            <option key={t.id} value={t.id}>{t.icon} {t.label}</option>
          ))}
        </select>
        <textarea
          placeholder={selectedAgents.length === 0 ? "Select agents first…" : "What should the agents work on?"}
          value={prompt}
          onChange={e => { setPrompt(e.target.value); autoResize(e); }}
          onKeyDown={onKeyDown}
          disabled={isRunning}
          className="prompt-input"
          rows={1}
          aria-label="Task prompt"
        />
        {voiceSupported && (
          <button onClick={onVoiceToggle} className={`action-btn ${voiceListening ? 'recording' : ''}`} title={voiceListening ? 'Stop voice input' : 'Start voice input'}>
            {voiceListening ? 'REC' : 'MIC'}
          </button>
        )}
        <button onClick={onSuggest} disabled={!prompt.trim() || suggesting || isRunning} className="action-btn suggest" title="Suggest agents">
          {suggesting ? '...' : 'Suggest'}
        </button>
        <button onClick={onDecompose} disabled={!prompt.trim() || decomposing || isRunning} className="action-btn" title="Decompose task (Ctrl+D)">
          {decomposing ? '...' : 'Split'}
        </button>
        <select
          className="workflow-select"
          value={workflowMode}
          onChange={e => onSetWorkflowMode(e.target.value as WorkflowMode)}
          title="Workflow mode"
        >
          {WORKFLOW_MODES.map(w => (
            <option key={w.mode} value={w.mode}>{w.icon} {w.label}</option>
          ))}
        </select>
        <button onClick={onSubmit} disabled={!prompt.trim() || selectedAgents.length === 0 || isRunning} className="action-btn primary" title="Submit">
          {isRunning ? '...' : 'Send'}
        </button>
        <button onClick={onAddToQueue} disabled={!prompt.trim() || isRunning} className="action-btn" title="Add to queue">+Q</button>
      </div>
    </div>
  );
}
