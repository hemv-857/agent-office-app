import React, { useState, useMemo } from 'react';
import type { Agent, AgentResult } from '../types';
import { exportResultsAsMarkdown, exportResultsAsJson, exportResultsAsHtml } from '../utils/export';

interface ResultsPanelProps {
  resultsArray: AgentResult[];
  allAgents: Agent[];
  totalCost: number;
  totalTokens: number;
  isRunning: boolean;
  expandedCards: Set<string>;
  compareMode: boolean;
  bookmarks: Set<string>;
  ratings: Map<string, 'up' | 'down'>;
  selectedResults: Set<string>;
  activeSession: string | null;
  resultsRef: React.RefObject<HTMLDivElement | null>;
  onSetCompareMode: (v: boolean | ((p: boolean) => boolean)) => void;
  onToggleCardExpanded: (id: string) => void;
  onToggleBookmark: (id: string) => void;
  onToggleRating: (id: string, dir: 'up' | 'down') => void;
  onToggleResultSelect: (id: string) => void;
  onSelectAllResults: () => void;
  onDeselectAllResults: () => void;
  onClearResults: () => void;
  onOpenChat: (id: string, name: string, emoji: string) => void;
  onCopyResult: (text: string) => void;
  onExportSingle: (r: AgentResult) => void;
  onShowResultsPanel: boolean;
  onEvaluateQuality?: (response: string, criteria: string) => Promise<{ passed: boolean; score: number; reasoning: string }>;
}

export function ResultsPanel({
  resultsArray,
  allAgents,
  totalCost,
  totalTokens,
  isRunning,
  expandedCards,
  compareMode,
  bookmarks,
  ratings,
  selectedResults,
  activeSession,
  resultsRef,
  onSetCompareMode,
  onToggleCardExpanded,
  onToggleBookmark,
  onToggleRating,
  onToggleResultSelect,
  onSelectAllResults,
  onDeselectAllResults,
  onClearResults,
  onOpenChat,
  onCopyResult,
  onExportSingle,
  onShowResultsPanel,
  onEvaluateQuality,
}: ResultsPanelProps) {
  const [resultSearch, setResultSearch] = useState('');
  const [qualityScores, setQualityScores] = useState<Map<string, { passed: boolean; score: number; reasoning: string }>>(new Map());
  const [evaluating, setEvaluating] = useState<Set<string>>(new Set());

  // Content analysis for compare mode
  const compareAnalysis = useMemo(() => {
    const completed = resultsArray.filter(r => r.status === 'completed' && r.response);
    if (completed.length < 2) return null;

    const extractKeywords = (text: string): Set<string> => {
      const words = text.toLowerCase().replace(/[^a-z0-9\s]/g, '').split(/\s+/);
      const stops = new Set(['the','a','an','is','are','was','were','be','been','being','have','has','had','do','does','did','will','would','could','should','may','might','shall','can','need','dare','ought','used','to','of','in','for','on','with','at','by','from','as','into','through','during','before','after','above','below','between','out','off','over','under','again','further','then','once','here','there','when','where','why','how','all','each','every','both','few','more','most','other','some','such','no','nor','not','only','own','same','so','than','too','very','just','because','but','and','or','if','while','that','this','these','those','it','its','they','them','their','what','which','who','whom']);
      return new Set(words.filter(w => w.length > 3 && !stops.has(w)));
    };

    const keywordSets = completed.map(r => extractKeywords(r.response));
    const allKeywords = new Set<string>();
    keywordSets.forEach(s => s.forEach(w => allKeywords.add(w)));

    // Find common keywords (appear in >50% of responses)
    const threshold = Math.ceil(completed.length * 0.5);
    const commonKeywords: string[] = [];
    const uniqueKeywords: string[][] = [];

    allKeywords.forEach(word => {
      const count = keywordSets.filter(s => s.has(word)).length;
      if (count >= threshold) commonKeywords.push(word);
    });

    completed.forEach((r, i) => {
      const unique = [...keywordSets[i]].filter(w => {
        const count = keywordSets.filter(s => s.has(w)).length;
        return count === 1;
      });
      uniqueKeywords.push(unique.slice(0, 5));
    });

    const lengths = completed.map(r => r.response.length);
    const maxLen = Math.max(...lengths);
    const minLen = Math.min(...lengths);

    return { completed, commonKeywords: commonKeywords.slice(0, 8), uniqueKeywords, maxLen, minLen };
  }, [resultsArray]);

  const filteredResults = resultSearch.trim()
    ? resultsArray.filter(r =>
        r.agent_name.toLowerCase().includes(resultSearch.toLowerCase()) ||
        r.response.toLowerCase().includes(resultSearch.toLowerCase())
      )
    : resultsArray;

  // Compute compare summary stats
  const completedResults = filteredResults.filter(r => r.status === 'completed');
  const avgTokens = completedResults.length > 0
    ? Math.round(completedResults.reduce((s, r) => s + r.tokens_used, 0) / completedResults.length)
    : 0;
  const fastestAgent = completedResults.reduce(
    (best, r) => !best || (r.elapsed_ms && r.elapsed_ms < best.elapsed_ms!) ? r : best,
    null as AgentResult | null,
  );
  const slowestAgent = completedResults.reduce(
    (worst, r) => !worst || (r.elapsed_ms && r.elapsed_ms > worst.elapsed_ms!) ? r : worst,
    null as AgentResult | null,
  );

  if (!onShowResultsPanel) return null;

  return (
    <div className="results-section" ref={resultsRef} style={{ position: 'relative' }} role="region" aria-label="Agent results">
      {isRunning && totalCost > 0 && (
        <div className="floating-cost">
          <span className="spinner-small" /> ${totalCost.toFixed(4)} · {totalTokens.toLocaleString()} tokens
        </div>
      )}
      <div className="results-header">
        <span>Results {filteredResults.length > 0 && `(${filteredResults.length})`}</span>
        {resultsArray.length > 0 && (
          <div className="results-header-actions">
            <input
              type="text"
              className="result-search-input"
              placeholder="search results…"
              value={resultSearch}
              onChange={e => setResultSearch(e.target.value)}
            />
            <span>{activeSession?.slice(0, 8)}</span>
            <span>${totalCost.toFixed(4)}</span>
            {selectedResults.size > 0 && (
              <>
                <button onClick={() => {
                  const texts = filteredResults
                    .filter(r => selectedResults.has(r.agent_id))
                    .map(r => `## ${r.agent_name}\n\n${r.response}`)
                    .join('\n\n---\n\n');
                  if (texts) onCopyResult(texts);
                }} className="link-btn" title={`Copy ${selectedResults.size} selected`}>📋×{selectedResults.size}</button>
                <button onClick={() => {
                  const data = filteredResults
                    .filter(r => selectedResults.has(r.agent_id))
                    .map(r => {
                      const agent = allAgents.find(a => a.id === r.agent_id);
                      return { agent: r.agent_name, emoji: agent?.emoji, role: agent?.office_role, status: r.status, response: r.response, tokens: r.tokens_used, cost: r.cost_usd, time_ms: r.elapsed_ms };
                    });
                  if (data.length > 0) {
                    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
                    const url = URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url; a.download = `agent-results-${Date.now()}.json`; a.click();
                    URL.revokeObjectURL(url);
                  }
                }} className="link-btn" title={`Export ${selectedResults.size} selected`}>📤×{selectedResults.size}</button>
              </>
            )}
            <button onClick={onSelectAllResults} className="link-btn" title="Select all">all</button>
            <button onClick={onDeselectAllResults} className="link-btn" title="Deselect all">none</button>
            <button onClick={() => onSetCompareMode((p: boolean) => !p)} className={`link-btn ${compareMode ? 'active' : ''}`} title="Compare mode">⟺</button>
            <button onClick={() => exportResultsAsMarkdown(resultsArray, allAgents)} className="link-btn" title="Export Markdown">📝</button>
            <button onClick={() => exportResultsAsJson(resultsArray, allAgents)} className="link-btn" title="Export JSON">{'{ }'}</button>
            <button onClick={() => exportResultsAsHtml(resultsArray, allAgents)} className="link-btn" title="Export HTML">🌐</button>
            <button onClick={onClearResults} className="link-btn">clear</button>
          </div>
        )}
      </div>
      <div className="results-body">
        {filteredResults.length > 0 ? (
          compareMode ? (
            <div className="compare-grid">
              {completedResults.length >= 2 && (
                <div className="compare-summary">
                  <div className="compare-stat">
                    <span className="compare-stat-label">Agents</span>
                    <span className="compare-stat-value">{completedResults.length}</span>
                  </div>
                  <div className="compare-stat">
                    <span className="compare-stat-label">Avg tokens</span>
                    <span className="compare-stat-value">{avgTokens.toLocaleString()}</span>
                  </div>
                  {fastestAgent && (
                    <div className="compare-stat">
                      <span className="compare-stat-label">Fastest</span>
                      <span className="compare-stat-value">⚡ {fastestAgent.agent_name} ({(fastestAgent.elapsed_ms! / 1000).toFixed(1)}s)</span>
                    </div>
                  )}
                  {slowestAgent && slowestAgent.agent_id !== fastestAgent?.agent_id && (
                    <div className="compare-stat">
                      <span className="compare-stat-label">Slowest</span>
                      <span className="compare-stat-value">🐢 {slowestAgent.agent_name} ({(slowestAgent.elapsed_ms! / 1000).toFixed(1)}s)</span>
                    </div>
                  )}
                  <div className="compare-stat">
                    <span className="compare-stat-label">Total cost</span>
                    <span className="compare-stat-value">${totalCost.toFixed(4)}</span>
                  </div>
                </div>
              )}
              {compareAnalysis && compareAnalysis.completed.length >= 2 && (
                <div className="compare-analysis">
                  {compareAnalysis.commonKeywords.length > 0 && (
                    <div className="compare-analysis-row">
                      <span className="compare-analysis-label">Shared themes</span>
                      <div className="keyword-tags">
                        {compareAnalysis.commonKeywords.map(k => (
                          <span key={k} className="keyword-tag common">{k}</span>
                        ))}
                      </div>
                    </div>
                  )}
                  <div className="compare-analysis-row">
                    <span className="compare-analysis-label">Response length</span>
                    <div className="length-bars">
                      {compareAnalysis.completed.map((r) => {
                        const pct = compareAnalysis.maxLen > 0 ? (r.response.length / compareAnalysis.maxLen) * 100 : 0;
                        const agent = allAgents.find(a => a.id === r.agent_id);
                        return (
                          <div key={r.agent_id} className="length-bar-row">
                            <span className="length-bar-label">{agent?.emoji || '🤖'} {r.agent_name.split(' ')[0]}</span>
                            <div className="length-bar-track">
                              <div className="length-bar-fill" style={{ width: `${pct}%` }} />
                            </div>
                            <span className="length-bar-value">{r.response.length.toLocaleString()}</span>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                </div>
              )}
              {filteredResults.map(r => {
                const agent = allAgents.find(a => a.id === r.agent_id);
                return (
                  <div key={r.agent_id} className={`compare-card ${r.status}`}>
                    <div className="compare-card-header">
                      <span>{agent?.emoji || '🤖'} {r.agent_name}</span>
                      {r.elapsed_ms !== undefined && <span className="result-time">{(r.elapsed_ms / 1000).toFixed(1)}s</span>}
                    </div>
                    <div className="compare-card-body">
                      {r.response || (r.status === 'working' ? <span className="streaming-cursor">▊</span> : '')}
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            filteredResults.map(r => {
              const agent = allAgents.find(a => a.id === r.agent_id);
              const expanded = expandedCards.has(r.agent_id);
              const isLong = r.response.length > 300;
              return (
                <div key={r.agent_id} className={`result-card ${r.status} ${selectedResults.has(r.agent_id) ? 'result-selected' : ''}`}>
                  <div className="result-card-header" onClick={() => isLong && onToggleCardExpanded(r.agent_id)} style={{ cursor: isLong ? 'pointer' : 'default' }}>
                    <span className="result-agent">
                      <span className={`result-select-check ${selectedResults.has(r.agent_id) ? 'active' : ''}`} onClick={e => { e.stopPropagation(); onToggleResultSelect(r.agent_id); }}>
                        {selectedResults.has(r.agent_id) ? '✓' : ''}
                      </span>
                      {agent?.emoji || '🤖'} {r.agent_name}
                    </span>
                    <div className="result-meta">
                      {r.elapsed_ms !== undefined && r.elapsed_ms > 0 && (
                        <span className="result-time">{(r.elapsed_ms / 1000).toFixed(1)}s</span>
                      )}
                      {r.cost_usd > 0 && <span className="result-cost">${r.cost_usd.toFixed(4)}</span>}
                      <div className="result-actions">
                        <button onClick={e => { e.stopPropagation(); onToggleBookmark(r.agent_id); }} className={`result-action-btn ${bookmarks.has(r.agent_id) ? 'bookmarked' : ''}`} title={bookmarks.has(r.agent_id) ? 'Unbookmark' : 'Bookmark'}>🔖</button>
                        <button onClick={e => { e.stopPropagation(); onToggleRating(r.agent_id, 'up'); }} className={`result-action-btn ${ratings.get(r.agent_id) === 'up' ? 'rated' : ''}`} title="Good response">👍</button>
                        <button onClick={e => { e.stopPropagation(); onToggleRating(r.agent_id, 'down'); }} className={`result-action-btn ${ratings.get(r.agent_id) === 'down' ? 'rated-down' : ''}`} title="Bad response">👎</button>
                        <button onClick={e => { e.stopPropagation(); onOpenChat(r.agent_id, r.agent_name, agent?.emoji || '🤖'); }} className="result-action-btn" title="Chat with agent">💬</button>
                        <button onClick={e => { e.stopPropagation(); onCopyResult(r.response); }} className="result-action-btn" title="Copy">📋</button>
                        <button onClick={e => { e.stopPropagation(); onExportSingle(r); }} className="result-action-btn" title="Export .md">📝</button>
                        {onEvaluateQuality && r.status === 'completed' && r.response && (
                          <button
                            onClick={async e => {
                              e.stopPropagation();
                              if (evaluating.has(r.agent_id)) return;
                              setEvaluating(prev => new Set(prev).add(r.agent_id));
                              const result = await onEvaluateQuality(r.response, 'Is this response helpful, accurate, and well-structured?');
                              setQualityScores(prev => new Map(prev).set(r.agent_id, result));
                              setEvaluating(prev => { const next = new Set(prev); next.delete(r.agent_id); return next; });
                            }}
                            className={`result-action-btn ${qualityScores.get(r.agent_id)?.passed === true ? 'rated' : qualityScores.get(r.agent_id)?.passed === false ? 'rated-down' : ''}`}
                            title={qualityScores.get(r.agent_id) ? `Score: ${(qualityScores.get(r.agent_id)!.score * 100).toFixed(0)}% — ${qualityScores.get(r.agent_id)!.reasoning}` : 'Evaluate quality'}
                          >
                            {evaluating.has(r.agent_id) ? '⏳' : '🛡'}
                          </button>
                        )}
                        {isLong && (
                          <button onClick={e => { e.stopPropagation(); onToggleCardExpanded(r.agent_id); }} className="result-action-btn" title={expanded ? 'Collapse' : 'Expand'}>
                            {expanded ? '▲' : '▼'}
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                  <div className={`result-body ${expanded ? '' : 'collapsed'}`}>
                    {r.response || (r.status === 'working' ? <span className="streaming-cursor">▊</span> : '')}
                  </div>
                </div>
              );
            })
          )
        ) : (
          <div className="results-empty">
            {resultSearch.trim() ? (
              <div className="empty-content">
                <div className="empty-title">No matches</div>
                <div className="empty-sub">No results for "{resultSearch}"</div>
              </div>
            ) : isRunning ? (
              <div className="empty-content">
                <div className="spinner" />
                <div className="empty-title">Agents working…</div>
              </div>
            ) : (
              <div className="empty-content">
                <div className="empty-icon">✨</div>
                <div className="empty-title">Build your team</div>
                <div className="empty-sub">
                  Select agents from the sidebar, then submit a prompt.<br />
                  Or press <kbd>?</kbd> for shortcuts.
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
