import { useState, useCallback } from 'react';
import { loadJson, saveJson } from '../utils/storage';

const STORAGE_KEY = 'agent-office-mcp-servers';

export interface McpServer {
  id: string;
  name: string;
  command: string;
  args: string[];
  env: Record<string, string>;
  enabled: boolean;
}

export function useMcpTools() {
  const [servers, setServers] = useState<McpServer[]>(() =>
    loadJson<McpServer[]>(STORAGE_KEY, [])
  );

  const addServer = useCallback((name: string, command: string, args: string[] = [], env: Record<string, string> = {}) => {
    const server: McpServer = {
      id: crypto.randomUUID(),
      name,
      command,
      args,
      env,
      enabled: true,
    };
    setServers(prev => {
      const next = [...prev, server];
      saveJson(STORAGE_KEY, next);
      return next;
    });
    return server;
  }, []);

  const removeServer = useCallback((id: string) => {
    setServers(prev => {
      const next = prev.filter(s => s.id !== id);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const toggleServer = useCallback((id: string) => {
    setServers(prev => {
      const next = prev.map(s => s.id === id ? { ...s, enabled: !s.enabled } : s);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const updateServer = useCallback((id: string, updates: Partial<Omit<McpServer, 'id'>>) => {
    setServers(prev => {
      const next = prev.map(s => s.id === id ? { ...s, ...updates } : s);
      saveJson(STORAGE_KEY, next);
      return next;
    });
  }, []);

  const enabledServers = servers.filter(s => s.enabled);

  return {
    servers,
    enabledServers,
    addServer,
    removeServer,
    toggleServer,
    updateServer,
  };
}
