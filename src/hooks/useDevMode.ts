import { useState, useEffect } from 'react';

interface DevInfo {
  renderCount: number;
  lastRenderTime: number;
  memoryUsage: number;
  localStorageSize: number;
}

export function useDevMode() {
  const [enabled, setEnabled] = useState(() =>
    localStorage.getItem('agent-office-dev-mode') === 'true'
  );
  const [info, setInfo] = useState<DevInfo>({
    renderCount: 0,
    lastRenderTime: 0,
    memoryUsage: 0,
    localStorageSize: 0,
  });

  useEffect(() => {
    if (!enabled) return;

    const interval = setInterval(() => {
      const memory = (performance as unknown as Record<string, unknown>).memory;
      const usedJSHeapSize = memory ? (memory as { usedJSHeapSize: number }).usedJSHeapSize : 0;

      let localStorageSize = 0;
      try {
        for (const key in localStorage) {
          if (Object.prototype.hasOwnProperty.call(localStorage, key)) {
            localStorageSize += localStorage.getItem(key)?.length || 0;
          }
        }
      } catch {
        // ignore
      }

      setInfo(prev => ({
        ...prev,
        memoryUsage: usedJSHeapSize,
        localStorageSize,
        lastRenderTime: performance.now(),
      }));
    }, 1000);

    return () => clearInterval(interval);
  }, [enabled]);

  const toggle = () => {
    const next = !enabled;
    setEnabled(next);
    localStorage.setItem('agent-office-dev-mode', String(next));
  };

  const incrementRender = () => {
    setInfo(prev => ({ ...prev, renderCount: prev.renderCount + 1 }));
  };

  return { enabled, info, toggle, incrementRender };
}
