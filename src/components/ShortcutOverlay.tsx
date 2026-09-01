import React from 'react';

interface ShortcutOverlayProps {
  open: boolean;
  onClose: () => void;
}

interface Shortcut {
  keys: string[];
  label: string;
}

const SECTIONS: { title: string; shortcuts: Shortcut[] }[] = [
  {
    title: 'General',
    shortcuts: [
      { keys: ['⌘', 'K'], label: 'Command palette' },
      { keys: ['⌘', 'Enter'], label: 'Run all agents' },
      { keys: ['⌘', 'D'], label: 'Decompose task' },
      { keys: ['⌘', ','], label: 'Open settings' },
      { keys: ['?'], label: 'Toggle help' },
      { keys: ['Esc'], label: 'Close modal / deselect' },
    ],
  },
  {
    title: 'Navigation',
    shortcuts: [
      { keys: ['⌘', '1-8'], label: 'Jump to agent desk' },
      { keys: ['↑', '↓'], label: 'Navigate agent list' },
      { keys: ['⌘', 'F'], label: 'Focus search' },
      { keys: ['⌘', 'B'], label: 'Toggle sidebar' },
    ],
  },
  {
    title: 'Agents',
    shortcuts: [
      { keys: ['⌘', 'A'], label: 'Select all agents' },
      { keys: ['⌘', 'D'], label: 'Deselect all' },
      { keys: ['Double-click'], label: 'Open agent detail' },
      { keys: ['Drag'], label: 'Seat agent at desk' },
    ],
  },
  {
    title: 'Results',
    shortcuts: [
      { keys: ['⌘', 'E'], label: 'Export results' },
      { keys: ['⌘', 'C'], label: 'Copy selected results' },
      { keys: ['Space'], label: 'Expand/collapse card' },
    ],
  },
];

export const ShortcutOverlay = React.memo(function ShortcutOverlay({ open, onClose }: ShortcutOverlayProps) {
  if (!open) return null;

  return (
    <div className="shortcut-overlay" onClick={onClose} role="dialog" aria-label="Keyboard shortcuts">
      <div className="shortcut-modal" onClick={e => e.stopPropagation()}>
        <div className="shortcut-header">
          <h2>Keyboard Shortcuts</h2>
          <button className="shortcut-close" onClick={onClose} aria-label="Close">✕</button>
        </div>
        <div className="shortcut-grid">
          {SECTIONS.map(section => (
            <div key={section.title} className="shortcut-section">
              <h3 className="shortcut-section-title">{section.title}</h3>
              {section.shortcuts.map(s => (
                <div key={s.label} className="shortcut-row">
                  <span className="shortcut-label">{s.label}</span>
                  <span className="shortcut-keys">
                    {s.keys.map((k, i) => (
                      <kbd key={i} className="shortcut-key">{k}</kbd>
                    ))}
                  </span>
                </div>
              ))}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
});
