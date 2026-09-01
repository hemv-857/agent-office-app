import { describe, it, expect } from 'vitest';
import { ROLES, ROLE_COLORS, TEMPLATES, STORAGE_KEYS } from '../constants';

describe('constants', () => {
  it('ROLES has 8 entries', () => {
    expect(ROLES).toHaveLength(8);
  });

  it('ROLE_COLORS has entries for all ROLES', () => {
    for (const role of ROLES) {
      expect(ROLE_COLORS[role]).toBeDefined();
      expect(typeof ROLE_COLORS[role]).toBe('string');
    }
  });

  it('TEMPLATES is non-empty', () => {
    expect(TEMPLATES.length).toBeGreaterThan(0);
    for (const t of TEMPLATES) {
      expect(t.label).toBeTruthy();
      expect(t.prompt).toBeTruthy();
    }
  });

  it('STORAGE_KEYS has expected keys', () => {
    expect(STORAGE_KEYS.theme).toBeTruthy();
    expect(STORAGE_KEYS.provider).toBeTruthy();
    expect(STORAGE_KEYS.seats).toBeTruthy();
  });
});
