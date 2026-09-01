import { useState, useMemo, useCallback, useEffect } from 'react';
import type { Agent } from '../types';
import { loadJson, saveJson } from '../utils/storage';
import { STORAGE_KEYS } from '../utils/constants';

export function useAgentSelection(allAgents: Agent[]) {
  const [selectedAgents, setSelectedAgents] = useState<string[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [roleFilter, setRoleFilter] = useState<string | null>(null);
  const [showFavoritesOnly, setShowFavoritesOnly] = useState(false);
  const [favorites, setFavorites] = useState<Set<string>>(() => {
    const raw = loadJson<string[] | Set<string>>(STORAGE_KEYS.favorites, []);
    return raw instanceof Set ? raw : new Set(Array.isArray(raw) ? raw : []);
  });

  const filteredAgents = useMemo(() => {
    return allAgents.filter(a => {
      const matchesSearch = !searchQuery ||
        a.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        a.description.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesRole = !roleFilter || a.office_role === roleFilter;
      const matchesFav = !showFavoritesOnly || favorites.has(a.id);
      return matchesSearch && matchesRole && matchesFav;
    });
  }, [allAgents, searchQuery, roleFilter, showFavoritesOnly, favorites]);

  const toggleAgent = useCallback((id: string) => {
    setSelectedAgents(prev =>
      prev.includes(id) ? prev.filter(a => a !== id) : [...prev, id]
    );
  }, []);

  const selectAll = useCallback(() => {
    setSelectedAgents(filteredAgents.map(a => a.id));
  }, [filteredAgents]);

  const deselectAll = useCallback(() => {
    setSelectedAgents([]);
  }, []);

  const toggleFavorite = useCallback((agentId: string) => {
    setFavorites(prev => {
      const next = new Set(prev);
      if (next.has(agentId)) next.delete(agentId);
      else next.add(agentId);
      return next;
    });
  }, []);

  useEffect(() => {
    saveJson(STORAGE_KEYS.favorites, [...favorites]);
  }, [favorites]);

  return {
    selectedAgents,
    setSelectedAgents,
    searchQuery,
    setSearchQuery,
    roleFilter,
    setRoleFilter,
    showFavoritesOnly,
    setShowFavoritesOnly,
    favorites,
    filteredAgents,
    toggleAgent,
    selectAll,
    deselectAll,
    toggleFavorite,
  };
}
