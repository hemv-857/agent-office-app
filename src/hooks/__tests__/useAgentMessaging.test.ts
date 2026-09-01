import { describe, it, expect, beforeEach } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useAgentMessaging } from '../useAgentMessaging';

describe('useAgentMessaging', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('starts with empty messages', () => {
    const { result } = renderHook(() => useAgentMessaging());
    expect(result.current.messages).toEqual([]);
  });

  it('sends a message', () => {
    const { result } = renderHook(() => useAgentMessaging());
    act(() => {
      result.current.sendMessage('agent-a', 'agent-b', 'Hello!');
    });
    expect(result.current.messages).toHaveLength(1);
    expect(result.current.messages[0].from).toBe('agent-a');
    expect(result.current.messages[0].to).toBe('agent-b');
    expect(result.current.messages[0].content).toBe('Hello!');
    expect(result.current.messages[0].read).toBe(false);
  });

  it('broadcasts to multiple recipients', () => {
    const { result } = renderHook(() => useAgentMessaging());
    act(() => {
      result.current.broadcast('agent-a', ['agent-b', 'agent-c', 'agent-d'], 'Broadcast msg');
    });
    expect(result.current.messages).toHaveLength(3);
  });

  it('marks messages as read', () => {
    const { result } = renderHook(() => useAgentMessaging());
    let msgId = '';
    act(() => {
      const msg = result.current.sendMessage('a', 'b', 'test');
      msgId = msg.id;
    });
    expect(result.current.messages[0].read).toBe(false);
    act(() => {
      result.current.markRead(msgId);
    });
    expect(result.current.messages[0].read).toBe(true);
  });

  it('gets unread count for agent', () => {
    const { result } = renderHook(() => useAgentMessaging());
    act(() => {
      result.current.sendMessage('a', 'b', 'msg1');
      result.current.sendMessage('a', 'b', 'msg2');
      result.current.sendMessage('b', 'a', 'msg3');
    });
    expect(result.current.getUnreadCount('b')).toBe(2);
    expect(result.current.getUnreadCount('a')).toBe(1);
  });

  it('gets conversation between two agents', () => {
    const { result } = renderHook(() => useAgentMessaging());
    act(() => {
      result.current.sendMessage('a', 'b', 'hello');
      result.current.sendMessage('b', 'a', 'hi there');
      result.current.sendMessage('c', 'd', 'other');
    });
    const convo = result.current.getConversation('a', 'b');
    expect(convo).toHaveLength(2);
  });

  it('clears all messages', () => {
    const { result } = renderHook(() => useAgentMessaging());
    act(() => {
      result.current.sendMessage('a', 'b', 'msg');
    });
    expect(result.current.messages).toHaveLength(1);
    act(() => {
      result.current.clearMessages();
    });
    expect(result.current.messages).toHaveLength(0);
  });
});
