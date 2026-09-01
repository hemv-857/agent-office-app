import { useEffect } from 'react';

interface UseKeyboardShortcutsProps {
  showHelp: boolean;
  setShowHelp: (v: boolean | ((p: boolean) => boolean)) => void;
  showSettings: boolean;
  setShowSettings: (v: boolean | ((p: boolean) => boolean)) => void;
  searchQuery: string;
  setSearchQuery: (v: string) => void;
  handleSuggest: () => void;
  handleRunAll?: () => void;
}

export function useKeyboardShortcuts({
  showHelp,
  setShowHelp,
  showSettings,
  setShowSettings,
  searchQuery,
  setSearchQuery,
  handleSuggest,
}: UseKeyboardShortcutsProps) {
  useEffect(() => {
    function handleGlobalKey(e: globalThis.KeyboardEvent) {
      const tag = (e.target as HTMLElement).tagName;
      const isInput = tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT';

      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        document.querySelector<HTMLInputElement>('.search-input')?.focus();
      }
      if (e.key === 'Escape') {
        if (showHelp) setShowHelp(false);
        else if (showSettings) setShowSettings(false);
        else if (searchQuery) setSearchQuery('');
      }
      if (e.key === '?' && !isInput) {
        e.preventDefault();
        setShowHelp(prev => !prev);
      }
      if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.key === ' ') {
        e.preventDefault();
        handleSuggest();
      }
    }
    window.addEventListener('keydown', handleGlobalKey);
    return () => window.removeEventListener('keydown', handleGlobalKey);
  }, [showSettings, searchQuery, showHelp, setShowHelp, setShowSettings, setSearchQuery, handleSuggest]);
}
