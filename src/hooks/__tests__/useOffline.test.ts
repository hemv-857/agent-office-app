import { describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('useOffline', () => {
  let originalOnLine: boolean;

  beforeEach(() => {
    originalOnLine = navigator.onLine;
  });

  afterEach(() => {
    Object.defineProperty(navigator, 'onLine', { value: originalOnLine, writable: true });
  });

  it('detects online state', () => {
    Object.defineProperty(navigator, 'onLine', { value: true, writable: true });
    expect(navigator.onLine).toBe(true);
  });

  it('detects offline state', () => {
    Object.defineProperty(navigator, 'onLine', { value: false, writable: true });
    expect(navigator.onLine).toBe(false);
  });

  it('responds to online event', () => {
    const events: string[] = [];
    const handler = () => events.push('online');
    window.addEventListener('online', handler);
    window.dispatchEvent(new Event('online'));
    expect(events).toContain('online');
    window.removeEventListener('online', handler);
  });

  it('responds to offline event', () => {
    const events: string[] = [];
    const handler = () => events.push('offline');
    window.addEventListener('offline', handler);
    window.dispatchEvent(new Event('offline'));
    expect(events).toContain('offline');
    window.removeEventListener('offline', handler);
  });
});
