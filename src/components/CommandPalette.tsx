import { useState, useEffect, useCallback, useRef, useMemo } from 'react';

export interface CommandItem {
  id: string;
  label: string;
  description?: string;
  icon?: string;
  shortcut?: string;
  group: string;
  action: () => void;
  keywords?: string[];
}

interface CommandPaletteProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  commands: CommandItem[];
}

function fuzzyMatch(query: string, text: string): boolean {
  const lower = query.toLowerCase();
  const target = text.toLowerCase();
  if (target.includes(lower)) return true;
  let qi = 0;
  for (let ti = 0; ti < target.length && qi < lower.length; ti++) {
    if (target[ti] === lower[qi]) qi++;
  }
  return qi === lower.length;
}

function fuzzyScore(query: string, text: string, keywords?: string[]): number {
  const lower = query.toLowerCase();
  const target = text.toLowerCase();
  let score = 0;
  if (target === lower) return 1000;
  if (target.startsWith(lower)) score += 500;
  else if (target.includes(lower)) score += 200;
  else {
    let qi = 0;
    for (let ti = 0; ti < target.length && qi < lower.length; ti++) {
      if (target[ti] === lower[qi]) { qi++; score += 10; }
    }
  }
  if (keywords) {
    for (const kw of keywords) {
      if (kw.toLowerCase().includes(lower)) score += 50;
    }
  }
  return score;
}

export function CommandPalette({ open, onOpenChange, commands }: CommandPaletteProps) {
  const [query, setQuery] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);
  const listRef = useRef<HTMLDivElement>(null);

  const filtered = useMemo(() => {
    if (!query.trim()) return commands;
    return commands
      .map(cmd => ({ ...cmd, _score: fuzzyScore(query, cmd.label, cmd.keywords) }))
      .filter(cmd => cmd._score > 0 || fuzzyMatch(query, cmd.label))
      .sort((a, b) => b._score - a._score);
  }, [query, commands]);

  const grouped = useMemo(() => {
    const map = new Map<string, CommandItem[]>();
    for (const cmd of filtered) {
      const arr = map.get(cmd.group) || [];
      arr.push(cmd);
      map.set(cmd.group, arr);
    }
    return Array.from(map.entries());
  }, [filtered]);

  const flatList = useMemo(() => filtered, [filtered]);

  const wasOpen = useRef(false);

  useEffect(() => {
    if (open && !wasOpen.current) {
      setQuery('');
      setSelectedIndex(0);
      setTimeout(() => inputRef.current?.focus(), 50);
    }
    wasOpen.current = open;
  }, [open]);

  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      onOpenChange(false);
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      setSelectedIndex(i => Math.min(i + 1, flatList.length - 1));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setSelectedIndex(i => Math.max(i - 1, 0));
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (flatList[selectedIndex]) {
        flatList[selectedIndex].action();
        onOpenChange(false);
      }
    }
  }, [flatList, selectedIndex, onOpenChange]);

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        onOpenChange(!open);
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [open, onOpenChange]);

  useEffect(() => {
    if (listRef.current) {
      const item = listRef.current.querySelector(`[data-index="${selectedIndex}"]`);
      item?.scrollIntoView({ block: 'nearest' });
    }
  }, [selectedIndex]);

  if (!open) return null;

  let runningIndex = -1;

  return (
    <div className="cmd-overlay" onClick={() => onOpenChange(false)} role="dialog" aria-label="Command palette">
      <div className="cmd-palette" onClick={e => e.stopPropagation()}>
        <div className="cmd-input-wrapper">
          <span className="cmd-search-icon">⌘</span>
          <input
            ref={inputRef}
            className="cmd-input"
            placeholder="Type a command…"
            value={query}
            onChange={e => setQuery(e.target.value)}
            onKeyDown={handleKeyDown}
            aria-label="Search commands"
          />
          <kbd className="cmd-kbd">ESC</kbd>
        </div>
        <div className="cmd-list" ref={listRef} role="listbox">
          {flatList.length === 0 && (
            <div className="cmd-empty">No commands found</div>
          )}
          {grouped.map(([group, items]) => (
            <div key={group} className="cmd-group">
              <div className="cmd-group-heading">{group}</div>
              {items.map(cmd => {
                runningIndex++;
                const idx = runningIndex;
                const isSelected = idx === selectedIndex;
                return (
                  <div
                    key={cmd.id}
                    className={`cmd-item ${isSelected ? 'selected' : ''}`}
                    data-index={idx}
                    role="option"
                    aria-selected={isSelected}
                    onClick={() => { cmd.action(); onOpenChange(false); }}
                    onMouseEnter={() => setSelectedIndex(idx)}
                  >
                    {cmd.icon && <span className="cmd-item-icon">{cmd.icon}</span>}
                    <div className="cmd-item-text">
                      <span className="cmd-item-label">{cmd.label}</span>
                      {cmd.description && <span className="cmd-item-desc">{cmd.description}</span>}
                    </div>
                    {cmd.shortcut && (
                      <kbd className="cmd-item-shortcut">{cmd.shortcut}</kbd>
                    )}
                  </div>
                );
              })}
            </div>
          ))}
        </div>
        <div className="cmd-footer">
          <span><kbd>↑</kbd><kbd>↓</kbd> navigate</span>
          <span><kbd>↵</kbd> select</span>
          <span><kbd>esc</kbd> close</span>
        </div>
      </div>
    </div>
  );
}
