import { describe, it, expect, beforeEach } from 'vitest';
import { loadString, saveString, loadJson, saveJson, loadBoolean } from '../storage';

describe('storage utils', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  describe('loadString', () => {
    it('returns fallback when key missing', () => {
      expect(loadString('missing', 'default')).toBe('default');
    });

    it('returns stored value', () => {
      localStorage.setItem('test-key', 'hello');
      expect(loadString('test-key', 'default')).toBe('hello');
    });
  });

  describe('saveString', () => {
    it('stores value', () => {
      saveString('test-key', 'hello');
      expect(localStorage.getItem('test-key')).toBe('hello');
    });
  });

  describe('loadJson', () => {
    it('returns fallback when key missing', () => {
      expect(loadJson<number[]>('missing', [1, 2])).toEqual([1, 2]);
    });

    it('parses stored JSON', () => {
      localStorage.setItem('arr', JSON.stringify([1, 2, 3]));
      expect(loadJson<number[]>('arr', [])).toEqual([1, 2, 3]);
    });

    it('returns fallback on corrupt JSON', () => {
      localStorage.setItem('bad', '{broken');
      expect(loadJson('bad', 'fallback')).toBe('fallback');
    });
  });

  describe('saveJson', () => {
    it('stores JSON string', () => {
      saveJson('obj', { a: 1 });
      expect(JSON.parse(localStorage.getItem('obj')!)).toEqual({ a: 1 });
    });
  });

  describe('loadBoolean', () => {
    it('returns fallback when key missing', () => {
      expect(loadBoolean('missing', true)).toBe(true);
    });

    it('returns true for "true"', () => {
      localStorage.setItem('bool', 'true');
      expect(loadBoolean('bool', false)).toBe(true);
    });

    it('returns false for "false"', () => {
      localStorage.setItem('bool', 'false');
      expect(loadBoolean('bool', true)).toBe(false);
    });
  });
});
