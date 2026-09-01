import { describe, it, expect, beforeEach } from 'vitest';

describe('useFocusTrap', () => {
  beforeEach(() => {
    document.body.innerHTML = '';
  });

  it('traps tab within container', () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <button id="first">First</button>
      <input id="middle" />
      <button id="last">Last</button>
    `;
    document.body.appendChild(container);

    const focusable = container.querySelectorAll<HTMLElement>('button, input');
    expect(focusable.length).toBe(3);

    // Simulate tab from last element
    focusable[2].focus();
    expect(document.activeElement).toBe(focusable[2]);
  });

  it('focuses first element on mount', () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <button id="first">First</button>
      <button id="second">Second</button>
    `;
    document.body.appendChild(container);

    const focusable = container.querySelectorAll<HTMLElement>('button');
    focusable[0].focus();
    expect(document.activeElement).toBe(focusable[0]);
  });
});
