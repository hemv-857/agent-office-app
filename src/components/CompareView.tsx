import React, { useMemo } from 'react';
import type { AgentResult } from '../types';

interface CompareViewProps {
  results: AgentResult[];
  onCopy: (text: string) => void;
}

export const CompareView = React.memo(function CompareView({ results, onCopy }: CompareViewProps) {
  const pairs = useMemo(() => {
    const completed = results.filter(r => r.status === 'completed');
    const pairs: AgentResult[][] = [];
    for (let i = 0; i < completed.length; i += 2) {
      pairs.push(completed.slice(i, i + 2));
    }
    return pairs;
  }, [results]);

  if (pairs.length === 0) return null;

  return (
    <div className="compare-view" role="region" aria-label="Side-by-side comparison">
      <div className="compare-header">
        <h3>Side-by-Side Comparison</h3>
      </div>
      {pairs.map((pair, pi) => (
        <div key={pi} className="compare-row">
          {pair.map(r => (
            <div key={r.agent_id} className="compare-card">
              <div className="compare-card-header">
                <span className="compare-agent-name">{r.agent_name}</span>
                <button className="link-btn" onClick={() => onCopy(r.response)} title="Copy">Copy</button>
              </div>
              <div className="compare-card-body">
                <pre className="compare-response">{r.response}</pre>
              </div>
              <div className="compare-card-footer">
                <span>{r.tokens_used} tokens</span>
                <span>${r.cost_usd.toFixed(4)}</span>
              </div>
            </div>
          ))}
          {pair.length === 1 && <div className="compare-card empty" />}
        </div>
      ))}
    </div>
  );
});
