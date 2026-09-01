import { useState, useCallback } from 'react';

export interface AgentMessage {
  id: string;
  from: string;
  to: string;
  content: string;
  timestamp: string;
  read: boolean;
  replyTo?: string;
}

export interface AgentConversation {
  agents: string[];
  messages: AgentMessage[];
}

export function useAgentMessaging() {
  const [messages, setMessages] = useState<AgentMessage[]>([]);
  const [conversations, setConversations] = useState<Map<string, AgentConversation>>(new Map());

  const sendMessage = useCallback((from: string, to: string, content: string, replyTo?: string) => {
    const msg: AgentMessage = {
      id: crypto.randomUUID(),
      from,
      to,
      content,
      timestamp: new Date().toISOString(),
      read: false,
      replyTo,
    };
    setMessages(prev => [...prev, msg]);

    // Update conversation index
    const key = [from, to].sort().join(':');
    setConversations(prev => {
      const next = new Map(prev);
      const existing = next.get(key) || { agents: [from, to], messages: [] };
      next.set(key, { ...existing, messages: [...existing.messages, msg] });
      return next;
    });

    return msg;
  }, []);

  const broadcast = useCallback((from: string, recipients: string[], content: string) => {
    return recipients.map(to => sendMessage(from, to, content));
  }, [sendMessage]);

  const markRead = useCallback((messageId: string) => {
    setMessages(prev => prev.map(m => m.id === messageId ? { ...m, read: true } : m));
  }, []);

  const getConversation = useCallback((agentA: string, agentB: string): AgentMessage[] => {
    const key = [agentA, agentB].sort().join(':');
    return conversations.get(key)?.messages || [];
  }, [conversations]);

  const getUnreadCount = useCallback((agentId: string): number => {
    return messages.filter(m => m.to === agentId && !m.read).length;
  }, [messages]);

  const getAgentMessages = useCallback((agentId: string): AgentMessage[] => {
    return messages.filter(m => m.from === agentId || m.to === agentId);
  }, [messages]);

  const clearMessages = useCallback(() => {
    setMessages([]);
    setConversations(new Map());
  }, []);

  return {
    messages,
    sendMessage,
    broadcast,
    markRead,
    getConversation,
    getUnreadCount,
    getAgentMessages,
    clearMessages,
  };
}
