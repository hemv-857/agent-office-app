import { useState } from 'react';
import { invoke } from '@tauri-apps/api/core';
import type { AgentDetail, CustomAgentForm, AgentStats, Theme } from '../types';
import { ROLES } from '../utils/constants';

// ============ Settings Modal ============
interface SettingsProps {
  provider: string;
  costBudget: number;
  onProviderChange: (p: string) => void;
  onBudgetChange: (b: number) => void;
  onSave: () => void;
  onClose: () => void;
  theme?: string;
  onThemeChange?: (t: Theme) => void;
}

export function SettingsModal({ provider, costBudget, onProviderChange, onBudgetChange, onSave, onClose, theme, onThemeChange }: SettingsProps) {
  const [anthropicKey, setAnthropicKey] = useState('');
  const [openaiKey, setOpenaiKey] = useState('');
  const [testingKey, setTestingKey] = useState<string | null>(null);
  const [showAnthropicKey, setShowAnthropicKey] = useState(false);
  const [showOpenaiKey, setShowOpenaiKey] = useState(false);
  const [saving, setSaving] = useState(false);

  function validateKeyFormat(provider: string, key: string): boolean {
    if (provider === 'anthropic') return key.startsWith('sk-ant-');
    if (provider === 'openai') return key.startsWith('sk-');
    return true;
  }

  async function testApiKey(p: string, key: string) {
    setTestingKey(p);
    try {
      const url = p === 'anthropic' ? 'https://api.anthropic.com/v1/messages' : 'https://api.openai.com/v1/chat/completions';
      const headers: Record<string, string> = p === 'anthropic'
        ? { 'x-api-key': key, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' }
        : { 'Authorization': `Bearer ${key}`, 'Content-Type': 'application/json' };
      const body = p === 'anthropic'
        ? JSON.stringify({ model: 'claude-3-5-haiku-20241022', max_tokens: 10, messages: [{ role: 'user', content: 'hi' }] })
        : JSON.stringify({ model: 'gpt-4o-mini', max_tokens: 10, messages: [{ role: 'user', content: 'hi' }] });
      const res = await fetch(url, { method: 'POST', headers, body });
      if (res.ok) {
        alert(`${p} key is valid`);
      } else {
        alert(`${p} key invalid: ${res.status}`);
      }
    } catch (e) {
      alert(`Connection failed: ${e}`);
    } finally {
      setTestingKey(null);
    }
  }

  async function handleSave() {
    setSaving(true);
    try {
      if (anthropicKey || openaiKey) {
        await invoke('set_api_keys', {
          anthropicKey: anthropicKey || null,
          openaiKey: openaiKey || null,
        });
      }
      onSave();
    } catch (e) {
      alert(`Failed to save keys: ${e}`);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <h2>Settings</h2>
        <div className="setting-group">
          <label className="setting-label">Model Provider</label>
          <select value={provider} onChange={e => onProviderChange(e.target.value)} className="setting-input">
            <option value="anthropic">Anthropic (Claude)</option>
            <option value="openai">OpenAI (GPT-4o)</option>
          </select>
        </div>
        {onThemeChange && (
          <div className="setting-group">
            <label className="setting-label">Theme</label>
            <select value={theme || 'dark'} onChange={e => onThemeChange(e.target.value as Theme)} className="setting-input">
              <option value="dark">Dark</option>
              <option value="light">Light</option>
              <option value="system">System Preference</option>
            </select>
          </div>
        )}
        <div className="setting-group">
          <label className="setting-label">Cost Budget ($, 0 = unlimited)</label>
          <input type="number" value={costBudget || ''} onChange={e => onBudgetChange(parseFloat(e.target.value) || 0)} placeholder="0.00" min="0" step="0.1" className="setting-input" />
        </div>
        <div className="setting-group">
          <label className="setting-label">Anthropic API Key</label>
          <div style={{ display: 'flex', gap: 8 }}>
            <input
              type={showAnthropicKey ? 'text' : 'password'}
              placeholder="sk-ant-..."
              value={anthropicKey}
              onChange={e => setAnthropicKey(e.target.value)}
              className="setting-input"
              style={{ flex: 1 }}
            />
            <button className="btn-test" onClick={() => setShowAnthropicKey(!showAnthropicKey)} title={showAnthropicKey ? 'Hide' : 'Show'}>
              {showAnthropicKey ? 'Hide' : 'Show'}
            </button>
            <button className="btn-test" disabled={!anthropicKey || testingKey !== null} onClick={() => testApiKey('anthropic', anthropicKey)}>
              {testingKey === 'anthropic' ? '...' : 'Test'}
            </button>
          </div>
          {anthropicKey && !validateKeyFormat('anthropic', anthropicKey) && (
            <span style={{ color: 'var(--red)', fontSize: 11, marginTop: 4, display: 'block' }}>
              Key should start with "sk-ant-"
            </span>
          )}
        </div>
        <div className="setting-group">
          <label className="setting-label">OpenAI API Key</label>
          <div style={{ display: 'flex', gap: 8 }}>
            <input
              type={showOpenaiKey ? 'text' : 'password'}
              placeholder="sk-..."
              value={openaiKey}
              onChange={e => setOpenaiKey(e.target.value)}
              className="setting-input"
              style={{ flex: 1 }}
            />
            <button className="btn-test" onClick={() => setShowOpenaiKey(!showOpenaiKey)} title={showOpenaiKey ? 'Hide' : 'Show'}>
              {showOpenaiKey ? 'Hide' : 'Show'}
            </button>
            <button className="btn-test" disabled={!openaiKey || testingKey !== null} onClick={() => testApiKey('openai', openaiKey)}>
              {testingKey === 'openai' ? '...' : 'Test'}
            </button>
          </div>
          {openaiKey && !validateKeyFormat('openai', openaiKey) && (
            <span style={{ color: 'var(--red)', fontSize: 11, marginTop: 4, display: 'block' }}>
              Key should start with "sk-"
            </span>
          )}
        </div>
        <div className="modal-actions">
          <button onClick={onClose} className="btn-secondary">Cancel</button>
          <button onClick={handleSave} disabled={saving} className="btn-primary">{saving ? 'Saving…' : 'Save'}</button>
        </div>
      </div>
    </div>
  );
}

// ============ Help Modal ============
export function HelpModal({ onClose }: { onClose: () => void }) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal-help" onClick={e => e.stopPropagation()}>
        <h2>Keyboard Shortcuts</h2>
        <div className="help-grid">
          <div className="help-item"><kbd>Enter</kbd><span>Submit prompt</span></div>
          <div className="help-item"><kbd>Ctrl/⌘+Enter</kbd><span>Submit prompt</span></div>
          <div className="help-item"><kbd>Shift+Enter</kbd><span>New line</span></div>
          <div className="help-item"><kbd>Ctrl/⌘+K</kbd><span>Focus search</span></div>
          <div className="help-item"><kbd>Ctrl/⌘+Shift+Space</kbd><span>Head Agent</span></div>
          <div className="help-item"><kbd>Escape</kbd><span>Close modal</span></div>
          <div className="help-item"><kbd>?</kbd><span>Toggle help</span></div>
          <div className="help-item"><span>Drag agent → desk</span><span>Seat at desk</span></div>
          <div className="help-item"><span>Double-click agent</span><span>Seat at role</span></div>
          <div className="help-item"><span>Click agent</span><span>View details</span></div>
          <div className="help-item"><span></span><span>Pipeline mode</span></div>
          <div className="help-item"><span></span><span>Head Agent suggest</span></div>
        </div>
        <div className="modal-actions">
          <button onClick={onClose} className="btn-primary">Close</button>
        </div>
      </div>
    </div>
  );
}

// ============ MCP Tools Modal ============
interface McpToolsProps {
  servers: { id: string; name: string; command: string; args: string[]; enabled: boolean }[];
  onAdd: (name: string, command: string, args: string[]) => void;
  onRemove: (id: string) => void;
  onToggle: (id: string) => void;
  onClose: () => void;
}

export function McpToolsModal({ servers, onAdd, onRemove, onToggle, onClose }: McpToolsProps) {
  const [name, setName] = useState('');
  const [command, setCommand] = useState('');
  const [argsStr, setArgsStr] = useState('');

  function handleAdd() {
    if (!name.trim() || !command.trim()) return;
    const args = argsStr.split(',').map(a => a.trim()).filter(Boolean);
    onAdd(name.trim(), command.trim(), args);
    setName('');
    setCommand('');
    setArgsStr('');
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 500 }}>
        <div className="modal-header">
          <h2>MCP Tool Registry</h2>
          <button className="modal-close" onClick={onClose}>×</button>
        </div>
        <div style={{ fontSize: 11, color: 'var(--text-3)', marginBottom: 10 }}>
          Connect Model Context Protocol servers to give agents access to external tools.
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginBottom: 12 }}>
          {servers.map(s => (
            <div key={s.id} style={{
              display: 'flex', alignItems: 'center', gap: 8, padding: '6px 10px',
              background: 'var(--bg-3)', borderRadius: 'var(--radius-sm)',
              opacity: s.enabled ? 1 : 0.5,
            }}>
              <button onClick={() => onToggle(s.id)} style={{
                background: 'none', border: 'none', cursor: 'pointer', fontSize: 14, padding: 0,
              }}>{s.enabled ? 'On' : 'Off'}</button>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 12, fontWeight: 600, color: 'var(--text-1)' }}>{s.name}</div>
                <div style={{ fontSize: 10, color: 'var(--text-4)', fontFamily: 'monospace', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                  {s.command} {s.args.join(' ')}
                </div>
              </div>
              <button onClick={() => onRemove(s.id)} style={{
                background: 'none', border: 'none', cursor: 'pointer', color: 'var(--red)', fontSize: 14, padding: 0,
              }}>×</button>
            </div>
          ))}
          {servers.length === 0 && (
            <div style={{ fontSize: 11, color: 'var(--text-4)', textAlign: 'center', padding: 16 }}>
              No MCP servers registered. Add one below.
            </div>
          )}
        </div>
        <div style={{ display: 'flex', gap: 6, marginBottom: 8 }}>
          <input value={name} onChange={e => setName(e.target.value)} placeholder="Name" style={{
            flex: 1, padding: '6px 8px', background: 'var(--bg-3)', border: '1px solid var(--border)',
            borderRadius: 'var(--radius-sm)', color: 'var(--text-1)', fontSize: 12,
          }} />
          <input value={command} onChange={e => setCommand(e.target.value)} placeholder="Command (e.g. npx)" style={{
            flex: 1, padding: '6px 8px', background: 'var(--bg-3)', border: '1px solid var(--border)',
            borderRadius: 'var(--radius-sm)', color: 'var(--text-1)', fontSize: 12,
          }} />
        </div>
        <div style={{ display: 'flex', gap: 6 }}>
          <input value={argsStr} onChange={e => setArgsStr(e.target.value)} placeholder="Args (comma-separated)" style={{
            flex: 1, padding: '6px 8px', background: 'var(--bg-3)', border: '1px solid var(--border)',
            borderRadius: 'var(--radius-sm)', color: 'var(--text-1)', fontSize: 12,
          }} />
          <button onClick={handleAdd} disabled={!name.trim() || !command.trim()} style={{
            padding: '6px 12px', background: name.trim() && command.trim() ? 'var(--accent)' : 'var(--bg-3)',
            border: '1px solid var(--border)', borderRadius: 'var(--radius-sm)',
            color: name.trim() && command.trim() ? 'white' : 'var(--text-4)', fontSize: 12, cursor: 'pointer',
          }}>Add</button>
        </div>
        <div className="modal-actions" style={{ marginTop: 12 }}>
          <button onClick={onClose} className="btn-primary">Done</button>
        </div>
      </div>
    </div>
  );
}

// ============ Agent Memory Panel ============
interface AgentMemoryProps {
  memories: { agentId: string; entries: { id: string; timestamp: string; task: string; lesson: string; tags: string[] }[] }[];
  onDelete: (agentId: string, entryId: string) => void;
  onClose: () => void;
}

export function AgentMemoryPanel({ memories, onDelete, onClose }: AgentMemoryProps) {
  const totalEntries = memories.reduce((sum, m) => sum + m.entries.length, 0);

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 520 }}>
        <div className="modal-header">
          <h2>Agent Memory</h2>
          <button className="modal-close" onClick={onClose}>×</button>
        </div>
        <div style={{ fontSize: 11, color: 'var(--text-3)', marginBottom: 10 }}>
          {totalEntries} lesson(s) across {memories.length} agent(s). Memories persist across sessions.
        </div>
        <div style={{ maxHeight: 300, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: 8 }}>
          {memories.map(m => (
            <div key={m.agentId}>
              <div style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)', marginBottom: 4 }}>
                Agent: {m.agentId}
              </div>
              {m.entries.map(e => (
                <div key={e.id} style={{
                  padding: '6px 10px', background: 'var(--bg-3)', borderRadius: 'var(--radius-sm)',
                  marginBottom: 4, fontSize: 11,
                }}>
                  <div style={{ color: 'var(--text-1)', marginBottom: 2 }}>{e.lesson}</div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div style={{ color: 'var(--text-4)', fontSize: 10 }}>
                      {e.tags.length > 0 && <span>[{e.tags.join(', ')}] </span>}
                      {new Date(e.timestamp).toLocaleDateString()}
                    </div>
                    <button onClick={() => onDelete(m.agentId, e.id)} style={{
                      background: 'none', border: 'none', cursor: 'pointer', color: 'var(--red)', fontSize: 10, padding: 0,
                    }}>delete</button>
                  </div>
                </div>
              ))}
            </div>
          ))}
          {memories.length === 0 && (
            <div style={{ fontSize: 11, color: 'var(--text-4)', textAlign: 'center', padding: 20 }}>
              No agent memories yet. Use agent memory to learn from past tasks.
            </div>
          )}
        </div>
        <div className="modal-actions" style={{ marginTop: 12 }}>
          <button onClick={onClose} className="btn-primary">Close</button>
        </div>
      </div>
    </div>
  );
}

// ============ Agent Detail Modal ============
export function AgentDetailModal({ detail, onClose }: { detail: AgentDetail; onClose: () => void }) {
  function copyPrompt() {
    navigator.clipboard.writeText(detail.system_prompt).catch(() => {});
  }
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal-detail" onClick={e => e.stopPropagation()}>
        <div className="detail-header">
          <span className="detail-emoji">{detail.name.charAt(0).toUpperCase()}</span>
          <div>
            <h2>{detail.name}</h2>
            <div className="detail-meta">
              <span className="detail-badge">{detail.division}</span>
              <span className="detail-badge">{detail.office_role}</span>
            </div>
          </div>
          <button className="modal-close" onClick={onClose}>×</button>
        </div>
        <p className="detail-desc">{detail.description}</p>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
          <h3 style={{ margin: 0 }}>System Prompt</h3>
          <button className="link-btn" onClick={copyPrompt} title="Copy system prompt">Copy</button>
        </div>
        <pre className="detail-prompt">{detail.system_prompt}</pre>
      </div>
    </div>
  );
}

// ============ Group Save Modal ============
interface GroupSaveProps {
  groupName: string;
  setGroupName: (v: string) => void;
  selectedCount: number;
  onSave: () => void;
  onClose: () => void;
}

export function GroupSaveModal({ groupName, setGroupName, selectedCount, onSave, onClose }: GroupSaveProps) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <h2>Save Agent Group</h2>
        <p className="detail-desc">{selectedCount} agents selected</p>
        <div className="form-group">
          <label>Group Name</label>
          <input value={groupName} onChange={e => setGroupName(e.target.value)} placeholder="e.g. frontend team" autoFocus onKeyDown={e => e.key === 'Enter' && onSave()} />
        </div>
        <div className="modal-actions">
          <button onClick={onClose} className="btn-secondary">Cancel</button>
          <button onClick={onSave} className="btn-primary">Save</button>
        </div>
      </div>
    </div>
  );
}

// ============ Preset Save Modal ============
interface PresetSaveProps {
  presetName: string;
  setPresetName: (v: string) => void;
  seatedCount: number;
  onSave: () => void;
  onClose: () => void;
}

export function PresetSaveModal({ presetName, setPresetName, seatedCount, onSave, onClose }: PresetSaveProps) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <h2>Save Office Preset</h2>
        <p className="detail-desc">{seatedCount} agents seated</p>
        <div className="form-group">
          <label>Preset Name</label>
          <input value={presetName} onChange={e => setPresetName(e.target.value)} placeholder="e.g. daily standup team" autoFocus onKeyDown={e => e.key === 'Enter' && onSave()} />
        </div>
        <div className="modal-actions">
          <button onClick={onClose} className="btn-secondary">Cancel</button>
          <button onClick={onSave} className="btn-primary">Save</button>
        </div>
      </div>
    </div>
  );
}

// ============ Custom Agent Modal ============
interface CustomAgentProps {
  customForm: CustomAgentForm;
  setCustomForm: (f: CustomAgentForm) => void;
  onAdd: () => void;
  onClose: () => void;
}

export function CustomAgentModal({ customForm, setCustomForm, onAdd, onClose }: CustomAgentProps) {
  const isValid = customForm.name.trim().length > 0
    && customForm.system_prompt.trim().length >= 10
    && customForm.name.length <= 100
    && customForm.description.length <= 500;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <h2>Add Custom Agent</h2>
        <div className="form-group">
          <label>Name <span style={{ color: 'var(--text-3)', fontSize: 11 }}>({customForm.name.length}/100)</span></label>
          <input value={customForm.name} onChange={e => setCustomForm({ ...customForm, name: e.target.value.slice(0, 100) })} placeholder="My Agent" />
        </div>
        <div className="form-group">
          <label>Emoji</label>
          <input value={customForm.emoji} onChange={e => setCustomForm({ ...customForm, emoji: e.target.value })} className="short-input" />
        </div>
        <div className="form-group">
          <label>Division</label>
          <input value={customForm.division} onChange={e => setCustomForm({ ...customForm, division: e.target.value })} />
        </div>
        <div className="form-group">
          <label>Role</label>
          <select value={customForm.office_role} onChange={e => setCustomForm({ ...customForm, office_role: e.target.value })}>
            {ROLES.map(r => <option key={r} value={r}>{r}</option>)}
          </select>
        </div>
        <div className="form-group">
          <label>Description <span style={{ color: 'var(--text-3)', fontSize: 11 }}>({customForm.description.length}/500)</span></label>
          <input value={customForm.description} onChange={e => setCustomForm({ ...customForm, description: e.target.value.slice(0, 500) })} placeholder="What this agent does" />
        </div>
        <div className="form-group">
          <label>System Prompt <span style={{ color: 'var(--red)', fontSize: 11 }}>(min 10 chars)</span></label>
          <textarea value={customForm.system_prompt} onChange={e => setCustomForm({ ...customForm, system_prompt: e.target.value })} rows={4} placeholder="You are a..." />
        </div>
        {!isValid && (
          <span style={{ color: 'var(--red)', fontSize: 12, marginBottom: 8, display: 'block' }}>
            {customForm.name.trim().length === 0 && 'Name is required. '}
            {customForm.system_prompt.trim().length < 10 && 'System prompt needs at least 10 characters. '}
          </span>
        )}
        <div className="modal-actions">
          <button onClick={onClose} className="btn-secondary">Cancel</button>
          <button onClick={onAdd} disabled={!isValid} className="btn-primary" style={{ opacity: isValid ? 1 : 0.5 }}>Add Agent</button>
        </div>
      </div>
    </div>
  );
}

// ============ Chat Modal ============
interface ChatProps {
  agent: { id: string; name: string; emoji: string };
  messages: { role: 'user' | 'agent'; text: string }[];
  chatInput: string;
  setChatInput: (v: string) => void;
  chatLoading: boolean;
  onSend: () => void;
  onClose: () => void;
}

export function ChatModal({ agent, messages, chatInput, setChatInput, chatLoading, onSend, onClose }: ChatProps) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal-chat" onClick={e => e.stopPropagation()}>
        <div className="chat-header">
          <span className="chat-agent-emoji">{agent.name.charAt(0).toUpperCase()}</span>
          <span className="chat-agent-name">{agent.name}</span>
          <button className="modal-close" onClick={onClose}>×</button>
        </div>
        <div className="chat-messages">
          {messages.length === 0 && (
            <div className="chat-empty">Send a follow-up message to this agent.</div>
          )}
          {messages.map((m, i) => (
            <div key={i} className={`chat-msg chat-${m.role}`}>
              <div className="chat-msg-role">{m.role === 'user' ? 'You' : agent.name}</div>
              <div className="chat-msg-text">{m.text}</div>
            </div>
          ))}
          {chatLoading && (
            <div className="chat-msg chat-agent">
              <div className="chat-msg-role">{agent.name}</div>
              <div className="chat-msg-text"><span className="spinner-small" /> thinking…</div>
            </div>
          )}
        </div>
        <div className="chat-input-row">
          <input
            type="text"
            className="chat-input"
            placeholder={`Ask ${agent.name}…`}
            value={chatInput}
            onChange={e => setChatInput(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && onSend()}
            disabled={chatLoading}
          />
          <button onClick={onSend} disabled={!chatInput.trim() || chatLoading} className="action-btn primary" style={{ width: 36, height: 36 }}>
            {chatLoading ? '...' : 'Send'}
          </button>
        </div>
      </div>
    </div>
  );
}

// ============ Performance Modal ============
interface PerfProps {
  resultsArray: AgentStats[];
  totalCost: number;
  totalTokens: number;
  ratings: Map<string, 'up' | 'down'>;
  onClose: () => void;
}

export function PerformanceModal({ resultsArray, totalCost, totalTokens, ratings, onClose }: PerfProps) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal modal-perf" onClick={e => e.stopPropagation()}>
        <h2>Performance Dashboard</h2>
        {resultsArray.length === 0 ? (
          <p className="detail-desc">No results yet. Run some agents to see stats.</p>
        ) : (
          <div className="perf-grid">
            <div className="perf-summary">
              <div className="perf-stat">
                <div className="perf-stat-value">{resultsArray.length}</div>
                <div className="perf-stat-label">Total Runs</div>
              </div>
              <div className="perf-stat">
                <div className="perf-stat-value">${totalCost.toFixed(4)}</div>
                <div className="perf-stat-label">Total Cost</div>
              </div>
              <div className="perf-stat">
                <div className="perf-stat-value">{totalTokens.toLocaleString()}</div>
                <div className="perf-stat-label">Total Tokens</div>
              </div>
            </div>
            <div className="perf-table">
              <div className="perf-table-header">
                <span>Agent</span>
                <span>Runs</span>
                <span>Cost</span>
                <span>Rating</span>
              </div>
              {resultsArray.map(s => (
                <div key={s.id} className="perf-table-row">
                  <span>{s.name.split(' ')[0]}</span>
                  <span>{s.runs}</span>
                  <span>${s.totalCost.toFixed(4)}</span>
                  <span>{ratings.get(s.id) === 'up' ? '' : ratings.get(s.id) === 'down' ? '' : '—'}</span>
                </div>
              ))}
            </div>
          </div>
        )}
        <div className="modal-actions">
          <button onClick={onClose} className="btn-primary">Close</button>
        </div>
      </div>
    </div>
  );
}

interface ApprovalModalProps {
  agentName: string;
  agentEmoji: string;
  context: string;
  onApprove: () => void;
  onReject: () => void;
}

export function ApprovalModal({ agentName, agentEmoji, context, onApprove, onReject }: ApprovalModalProps) {
  return (
    <div className="modal-overlay" onClick={onReject}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header">
          <h2> Approve Next Step</h2>
          <button className="modal-close" onClick={onReject}>×</button>
        </div>
        <div style={{ padding: '4px 0' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 12 }}>
            <span style={{ fontSize: 28 }}>{agentEmoji}</span>
            <div>
              <div style={{ fontWeight: 600, fontSize: 14 }}>{agentName}</div>
              <div style={{ fontSize: 12, color: 'var(--text-3)' }}>is ready to process</div>
            </div>
          </div>
          <div style={{ fontSize: 12, color: 'var(--text-2)', marginBottom: 8, fontWeight: 500 }}>Context from previous steps:</div>
          <div style={{
            background: 'var(--bg-3)',
            border: '1px solid var(--border)',
            borderRadius: 'var(--radius)',
            padding: '10px 12px',
            fontSize: 12,
            color: 'var(--text-2)',
            maxHeight: 200,
            overflow: 'auto',
            lineHeight: 1.5,
            whiteSpace: 'pre-wrap',
          }}>
            {context.length > 500 ? context.slice(0, 500) + '…' : context}
          </div>
        </div>
        <div className="modal-actions">
          <button onClick={onReject} className="btn-secondary">Reject</button>
          <button onClick={onApprove} className="btn-primary">Approve & Continue</button>
        </div>
      </div>
    </div>
  );
}

// ============ Overnight Panel ============
interface OvernightPanelProps {
  isRunning: boolean;
  iteration: number;
  maxIterations: number;
  totalTokens: number;
  maxTokens: number;
  totalCost: number;
  commits: number;
  rollbacks: number;
  lastError: string | null;
  onStart: (objective: string, maxIter: number, maxTok: number, preventSleep: boolean) => void;
  onStop: () => void;
}

export function OvernightPanel({
  isRunning,
  iteration,
  maxIterations,
  totalTokens,
  maxTokens,
  totalCost,
  commits,
  rollbacks,
  lastError,
  onStart,
  onStop,
}: OvernightPanelProps) {
  const [objective, setObjective] = useState('');
  const [maxIter, setMaxIter] = useState(10);
  const [maxTok, setMaxTok] = useState(1_000_000);
  const [preventSleep, setPreventSleep] = useState(true);

  if (isRunning) {
    const pct = maxIterations > 0 ? (iteration / maxIterations) * 100 : 0;
    const tokenPct = maxTokens > 0 ? (totalTokens / maxTokens) * 100 : 0;
    return (
      <div style={{
        background: 'var(--bg-2)',
        border: '1px solid var(--accent)',
        borderRadius: 'var(--radius)',
        padding: '12px 16px',
        marginBottom: 10,
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
          <span style={{ fontWeight: 600, fontSize: 13, color: 'var(--accent)' }}> Overnight Running</span>
          <button onClick={onStop} style={{
            background: 'var(--red-dim)',
            border: '1px solid var(--red)',
            color: 'var(--red)',
            borderRadius: 'var(--radius-sm)',
            padding: '4px 12px',
            fontSize: 11,
            fontWeight: 600,
            cursor: 'pointer',
          }}>Stop</button>
        </div>
        <div style={{ display: 'flex', gap: 16, fontSize: 12, color: 'var(--text-2)', marginBottom: 8 }}>
          <span>Iteration {iteration}/{maxIterations}</span>
          <span>Tokens {(totalTokens / 1000).toFixed(0)}k/{(maxTokens / 1000).toFixed(0)}k</span>
          <span>Cost ${totalCost.toFixed(4)}</span>
          <span>Commits {commits}</span>
          {rollbacks > 0 && <span style={{ color: 'var(--red)' }}>Rollbacks {rollbacks}</span>}
        </div>
        <div style={{ display: 'flex', gap: 6, marginBottom: 4 }}>
          <div style={{ flex: 1, height: 4, background: 'var(--bg-3)', borderRadius: 2, overflow: 'hidden' }}>
            <div style={{ height: '100%', width: `${pct}%`, background: 'var(--accent)', borderRadius: 2, transition: 'width 0.3s' }} />
          </div>
          <div style={{ flex: 1, height: 4, background: 'var(--bg-3)', borderRadius: 2, overflow: 'hidden' }}>
            <div style={{ height: '100%', width: `${tokenPct}%`, background: tokenPct > 80 ? 'var(--yellow)' : 'var(--green)', borderRadius: 2, transition: 'width 0.3s' }} />
          </div>
        </div>
        {lastError && (
          <div style={{ fontSize: 11, color: 'var(--red)', marginTop: 6 }}> {lastError}</div>
        )}
      </div>
    );
  }

  return (
    <div style={{
      background: 'var(--bg-2)',
      border: '1px solid var(--border)',
      borderRadius: 'var(--radius)',
      padding: '12px 16px',
      marginBottom: 10,
    }}>
      <div style={{ fontWeight: 600, fontSize: 13, marginBottom: 10 }}> Overnight Mode</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <input
          type="text"
          placeholder="Objective (what should agents work on overnight?)"
          value={objective}
          onChange={e => setObjective(e.target.value)}
          style={{
            padding: '8px 12px',
            border: '1px solid var(--border)',
            borderRadius: 'var(--radius)',
            background: 'var(--bg-3)',
            color: 'var(--text-1)',
            fontSize: 12,
            fontFamily: 'inherit',
          }}
        />
        <div style={{ display: 'flex', gap: 8 }}>
          <label style={{ fontSize: 11, color: 'var(--text-3)', display: 'flex', alignItems: 'center', gap: 4 }}>
            Max iterations:
            <input
              type="number"
              value={maxIter}
              onChange={e => setMaxIter(Number(e.target.value))}
              min={1}
              max={100}
              style={{ width: 50, padding: '4px 6px', border: '1px solid var(--border)', borderRadius: 'var(--radius-sm)', background: 'var(--bg-3)', color: 'var(--text-1)', fontSize: 11 }}
            />
          </label>
          <label style={{ fontSize: 11, color: 'var(--text-3)', display: 'flex', alignItems: 'center', gap: 4 }}>
            Max tokens:
            <input
              type="number"
              value={maxTok}
              onChange={e => setMaxTok(Number(e.target.value))}
              min={10000}
              step={100000}
              style={{ width: 80, padding: '4px 6px', border: '1px solid var(--border)', borderRadius: 'var(--radius-sm)', background: 'var(--bg-3)', color: 'var(--text-1)', fontSize: 11 }}
            />
          </label>
          <label style={{ fontSize: 11, color: 'var(--text-3)', display: 'flex', alignItems: 'center', gap: 4, cursor: 'pointer' }}>
            <input
              type="checkbox"
              checked={preventSleep}
              onChange={e => setPreventSleep(e.target.checked)}
              style={{ cursor: 'pointer' }}
            />
            Prevent sleep
          </label>
        </div>
        <button
          onClick={() => onStart(objective, maxIter, maxTok, preventSleep)}
          disabled={!objective.trim()}
          style={{
            padding: '8px 16px',
            background: objective.trim() ? 'var(--accent)' : 'var(--bg-3)',
            border: '1px solid ' + (objective.trim() ? 'var(--accent)' : 'var(--border)'),
            borderRadius: 'var(--radius)',
            color: objective.trim() ? 'white' : 'var(--text-4)',
            fontSize: 12,
            fontWeight: 600,
            cursor: objective.trim() ? 'pointer' : 'not-allowed',
            fontFamily: 'inherit',
          }}
        >
           Start Overnight Run
        </button>
      </div>
    </div>
  );
}

// ============ Exit Summary Modal ============
interface ExitSummaryProps {
  summary: {
    iterations: number;
    totalTokens: number;
    totalCost: number;
    commits: number;
    rollbacks: number;
    elapsedMs: number;
    branch: string;
  };
  onClose: () => void;
}

export function ExitSummaryModal({ summary, onClose }: ExitSummaryProps) {
  const hours = Math.floor(summary.elapsedMs / 3_600_000);
  const minutes = Math.floor((summary.elapsedMs % 3_600_000) / 60_000);
  const seconds = Math.floor((summary.elapsedMs % 60_000) / 1000);

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 420 }}>
        <div className="modal-header">
          <h2> Overnight Run Complete</h2>
          <button className="modal-close" onClick={onClose}>×</button>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, padding: '4px 0' }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
            {[
              { label: 'Iterations', value: `${summary.iterations}` },
              { label: 'Commits', value: `${summary.commits}`, color: 'var(--green)' },
              { label: 'Rollbacks', value: `${summary.rollbacks}`, color: summary.rollbacks > 0 ? 'var(--red)' : undefined },
              { label: 'Tokens', value: `~${(summary.totalTokens / 1000).toFixed(0)}k` },
              { label: 'Cost', value: `$${summary.totalCost.toFixed(4)}` },
              { label: 'Time', value: `${hours}h ${minutes}m ${seconds}s` },
            ].map(item => (
              <div key={item.label} style={{
                background: 'var(--bg-3)',
                borderRadius: 'var(--radius-sm)',
                padding: '8px 12px',
              }}>
                <div style={{ fontSize: 10, color: 'var(--text-4)', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 2 }}>{item.label}</div>
                <div style={{ fontSize: 16, fontWeight: 600, color: item.color || 'var(--text-1)' }}>{item.value}</div>
              </div>
            ))}
          </div>
          {summary.branch && (
            <div style={{ fontSize: 11, color: 'var(--text-3)', textAlign: 'center' }}>
              Branch: <code style={{ background: 'var(--bg-3)', padding: '2px 6px', borderRadius: 4 }}>{summary.branch}</code>
            </div>
          )}
          <div style={{ fontSize: 11, color: 'var(--text-4)', textAlign: 'center', lineHeight: 1.4 }}>
            Each iteration committed one batch of agent results.{' '}
            {summary.rollbacks > 0 && `${summary.rollbacks} iteration(s) were rolled back due to errors.`}
          </div>
        </div>
        <div className="modal-actions">
          <button onClick={onClose} className="btn-primary">Close</button>
        </div>
      </div>
    </div>
  );
}

// ============ Cost Tracker Modal ============
interface CostTrackerProps {
  entries: { id: string; timestamp: string; prompt: string; provider: string; totalCost: number; totalTokens: number }[];
  todayCost: number;
  totalCost: number;
  weeklyCost: number;
  byProvider: Record<string, number>;
  budget: { dailyLimit: number; perSessionLimit: number; alertThreshold: number };
  budgetCheck: { ok: boolean; warning: boolean; message: string };
  onSetBudget: (config: { dailyLimit?: number; perSessionLimit?: number; alertThreshold?: number }) => void;
  onClose: () => void;
}

export function CostTrackerModal({ entries, todayCost, totalCost, weeklyCost, byProvider, budget, budgetCheck, onSetBudget, onClose }: CostTrackerProps) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 520 }}>
        <div className="modal-header">
          <h2>Cost Tracker</h2>
          <button className="modal-close" onClick={onClose}>×</button>
        </div>
        {budgetCheck.warning && (
          <div style={{
            padding: '8px 12px', borderRadius: 'var(--radius-sm)',
            background: budgetCheck.ok ? 'rgba(232, 212, 124, 0.15)' : 'rgba(232, 116, 124, 0.15)',
            color: budgetCheck.ok ? 'var(--accent)' : 'var(--red)',
            fontSize: 12, marginBottom: 10,
          }}>
            {budgetCheck.message}
          </div>
        )}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8, marginBottom: 12 }}>
          {[
            { label: 'Today', value: `$${todayCost.toFixed(4)}` },
            { label: 'This Week', value: `$${weeklyCost.toFixed(4)}` },
            { label: 'All Time', value: `$${totalCost.toFixed(4)}` },
          ].map(item => (
            <div key={item.label} style={{
              background: 'var(--bg-3)', borderRadius: 'var(--radius-sm)', padding: '8px 12px', textAlign: 'center',
            }}>
              <div style={{ fontSize: 10, color: 'var(--text-4)', textTransform: 'uppercase', marginBottom: 2 }}>{item.label}</div>
              <div style={{ fontSize: 16, fontWeight: 600, color: 'var(--text-1)' }}>{item.value}</div>
            </div>
          ))}
        </div>
        <div style={{ marginBottom: 12 }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)', marginBottom: 6 }}>By Provider</div>
          {Object.entries(byProvider).map(([name, cost]) => (
            <div key={name} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, padding: '3px 0' }}>
              <span style={{ color: 'var(--text-3)' }}>{name}</span>
              <span style={{ color: 'var(--text-1)', fontFamily: 'monospace' }}>${cost.toFixed(4)}</span>
            </div>
          ))}
          {Object.keys(byProvider).length === 0 && (
            <div style={{ fontSize: 11, color: 'var(--text-4)' }}>No costs recorded yet</div>
          )}
        </div>
        <div style={{ marginBottom: 12, padding: '8px 10px', background: 'var(--bg-3)', borderRadius: 'var(--radius-sm)' }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: 'var(--text-2)', marginBottom: 6 }}>Budget Limits</div>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center', fontSize: 12 }}>
            <label style={{ color: 'var(--text-3)', flex: 1 }}>Daily ($)</label>
            <input
              type="number"
              value={budget.dailyLimit || ''}
              onChange={e => onSetBudget({ dailyLimit: parseFloat(e.target.value) || 0 })}
              placeholder="0 = unlimited"
              style={{
                width: 100, padding: '4px 8px', background: 'var(--bg-2)', border: '1px solid var(--border)',
                borderRadius: 'var(--radius-sm)', color: 'var(--text-1)', fontSize: 12,
              }}
            />
          </div>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center', fontSize: 12, marginTop: 4 }}>
            <label style={{ color: 'var(--text-3)', flex: 1 }}>Per Session ($)</label>
            <input
              type="number"
              value={budget.perSessionLimit || ''}
              onChange={e => onSetBudget({ perSessionLimit: parseFloat(e.target.value) || 0 })}
              placeholder="0 = unlimited"
              style={{
                width: 100, padding: '4px 8px', background: 'var(--bg-2)', border: '1px solid var(--border)',
                borderRadius: 'var(--radius-sm)', color: 'var(--text-1)', fontSize: 12,
              }}
            />
          </div>
        </div>
        <div style={{ maxHeight: 150, overflowY: 'auto' }}>
          {entries.slice(0, 10).map(e => (
            <div key={e.id} style={{
              display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              padding: '4px 8px', fontSize: 11, borderBottom: '1px solid var(--border)',
            }}>
              <span style={{ color: 'var(--text-3)', flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                {e.prompt.slice(0, 50)}
              </span>
              <span style={{ color: 'var(--text-4)', marginLeft: 8, flexShrink: 0 }}>{e.provider}</span>
              <span style={{ color: 'var(--text-1)', marginLeft: 8, fontFamily: 'monospace', flexShrink: 0 }}>${e.totalCost.toFixed(4)}</span>
            </div>
          ))}
        </div>
        <div className="modal-actions" style={{ marginTop: 12 }}>
          <button onClick={onClose} className="btn-primary">Close</button>
        </div>
      </div>
    </div>
  );
}

// ============ Leaderboard Modal ============
interface LeaderboardProps {
  entries: { agentId: string; name: string; emoji: string; runs: number; successes: number; failures: number; totalCost: number; avgTimeMs: number; successRate: number; avgCostPerRun: number }[];
  mostEfficient: { agentId: string; name: string; emoji: string; successRate: number; avgCostPerRun: number } | null;
  onClear: () => void;
  onClose: () => void;
}

export function LeaderboardModal({ entries, mostEfficient, onClear, onClose }: LeaderboardProps) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()} style={{ maxWidth: 520 }}>
        <div className="modal-header">
          <h2>Agent Leaderboard</h2>
          <button className="modal-close" onClick={onClose}>×</button>
        </div>
        {mostEfficient && (
          <div style={{
            padding: '8px 12px', background: 'rgba(167, 232, 124, 0.1)', borderRadius: 'var(--radius-sm)',
            marginBottom: 10, fontSize: 12,
          }}>
            Most Efficient: <strong>{mostEfficient.name}</strong> — {mostEfficient.successRate.toFixed(0)}% success, ${mostEfficient.avgCostPerRun.toFixed(4)}/run
          </div>
        )}
        <div style={{ maxHeight: 300, overflowY: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 11 }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border)' }}>
                {['#', 'Agent', 'Runs', 'Success', 'Cost', 'Avg Time'].map(h => (
                  <th key={h} style={{ textAlign: 'left', padding: '6px 8px', color: 'var(--text-4)', fontWeight: 600 }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {entries.map((e, i) => (
                <tr key={e.agentId} style={{ borderBottom: '1px solid var(--border)' }}>
                  <td style={{ padding: '6px 8px', color: 'var(--text-4)' }}>{i + 1}</td>
                  <td style={{ padding: '6px 8px', color: 'var(--text-1)' }}>{e.name}</td>
                  <td style={{ padding: '6px 8px', color: 'var(--text-2)' }}>{e.runs}</td>
                  <td style={{ padding: '6px 8px', color: e.successRate >= 80 ? 'var(--green)' : e.successRate >= 50 ? 'var(--accent)' : 'var(--red)' }}>
                    {e.successRate.toFixed(0)}%
                  </td>
                  <td style={{ padding: '6px 8px', color: 'var(--text-2)', fontFamily: 'monospace' }}>${e.totalCost.toFixed(4)}</td>
                  <td style={{ padding: '6px 8px', color: 'var(--text-3)' }}>{(e.avgTimeMs / 1000).toFixed(1)}s</td>
                </tr>
              ))}
            </tbody>
          </table>
          {entries.length === 0 && (
            <div style={{ fontSize: 11, color: 'var(--text-4)', textAlign: 'center', padding: 20 }}>
              No agent runs recorded yet. Run some tasks to build the leaderboard.
            </div>
          )}
        </div>
        <div className="modal-actions" style={{ marginTop: 12 }}>
          <button onClick={onClear} style={{
            padding: '6px 12px', background: 'none', border: '1px solid var(--border)',
            borderRadius: 'var(--radius-sm)', color: 'var(--text-4)', fontSize: 11, cursor: 'pointer',
          }}>Clear History</button>
          <button onClick={onClose} className="btn-primary">Close</button>
        </div>
      </div>
    </div>
  );
}
