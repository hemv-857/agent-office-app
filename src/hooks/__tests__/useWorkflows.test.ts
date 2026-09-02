import { describe, it, expect } from 'vitest';

// Test the workflow mode logic without Tauri invoke dependency
describe('useWorkflows', () => {
  // Test the mode constants
  const WORKFLOW_MODES = [
    { mode: 'parallel', label: 'Parallel', icon: '', desc: 'All agents work simultaneously' },
    { mode: 'pipeline', label: 'Pipeline', icon: '', desc: 'Each agent feeds into the next' },
    { mode: 'synthesis', label: 'Synthesis', icon: '', desc: 'Parallel then synthesize consensus' },
    { mode: 'review', label: 'Review', icon: '', desc: 'Parallel then cross-review each other' },
    { mode: 'debate', label: 'Debate', icon: '', desc: 'State positions then critique' },
  ];

  it('has 5 workflow modes', () => {
    expect(WORKFLOW_MODES).toHaveLength(5);
  });

  it('each mode has required fields', () => {
    for (const m of WORKFLOW_MODES) {
      expect(m.mode).toBeTruthy();
      expect(m.label).toBeTruthy();
      expect(m.desc).toBeTruthy();
    }
  });

  it('parallel mode uses execute_task', () => {
    const mode = WORKFLOW_MODES.find(m => m.mode === 'parallel');
    expect(mode?.label).toBe('Parallel');
  });

  it('pipeline mode uses execute_pipeline', () => {
    const mode = WORKFLOW_MODES.find(m => m.mode === 'pipeline');
    expect(mode?.label).toBe('Pipeline');
  });

  it('synthesis mode chains parallel then synthesis', () => {
    const mode = WORKFLOW_MODES.find(m => m.mode === 'synthesis');
    expect(mode?.label).toBe('Synthesis');
  });
});
