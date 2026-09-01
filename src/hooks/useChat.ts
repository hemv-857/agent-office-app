import { useState, useEffect, useRef } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { listen } from '@tauri-apps/api/event';
import type { ChatMessage } from '../types';

export function useChat(provider: string) {
  const [chatAgent, setChatAgent] = useState<{ id: string; name: string; emoji: string } | null>(null);
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([]);
  const [chatInput, setChatInput] = useState('');
  const [chatLoading, setChatLoading] = useState(false);
  const sessionIdRef = useRef<string | null>(null);

  function openChat(agentId: string, agentName: string, agentEmoji: string) {
    setChatAgent({ id: agentId, name: agentName, emoji: agentEmoji });
    setChatMessages([]);
    setChatInput('');
  }

  useEffect(() => {
    if (!sessionIdRef.current) return;
    const sid = sessionIdRef.current;
    const unlisten = listen('agent-stream', (event: { payload: { session_id: string; agent_id: string; event_type: string; text: string } }) => {
      const p = event.payload;
      if (p.session_id !== sid) return;
      if (p.event_type === 'done' && p.text) {
        setChatMessages(prev => [...prev, { role: 'agent', text: p.text }]);
        setChatLoading(false);
        sessionIdRef.current = null;
      } else if (p.event_type === 'error') {
        setChatMessages(prev => [...prev, { role: 'agent', text: p.text }]);
        setChatLoading(false);
        sessionIdRef.current = null;
      }
    });
    return () => { unlisten.then(fn => fn()); };
  }, [chatLoading]);

  async function sendChatMessage() {
    if (!chatInput.trim() || !chatAgent || chatLoading) return;
    const msg = chatInput.trim();
    setChatInput('');
    setChatMessages(prev => [...prev, { role: 'user', text: msg }]);
    setChatLoading(true);
    try {
      const sessionId: string = await invoke('execute_task', {
        request: {
          prompt: msg,
          agent_ids: [chatAgent.id],
          provider,
          model: null,
          temperature: 0.7,
        }
      });
      sessionIdRef.current = sessionId;
    } catch (e) {
      setChatMessages(prev => [...prev, { role: 'agent', text: `Error: ${typeof e === 'string' ? e : 'Failed'}` }]);
      setChatLoading(false);
    }
  }

  return {
    chatAgent,
    setChatAgent,
    chatMessages,
    chatInput,
    setChatInput,
    chatLoading,
    openChat,
    sendChatMessage,
  };
}
