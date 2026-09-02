import { useState } from 'react';

interface OnboardingProps {
  onComplete: () => void;
}

const STEPS = [
  {
    title: 'Welcome to Agent Office',
    description: 'A multi-agent AI workspace where specialized agents collaborate on tasks. Think of it as your AI command center.',
    icon: '🏢',
  },
  {
    title: 'Seat Your Agents',
    description: 'Drag agents from the sidebar onto the office grid. Each desk represents a role — developer, QA, architect, and more.',
    icon: '🪑',
  },
  {
    title: 'Write a Prompt',
    description: 'Type what you want in the prompt bar. Use templates for common workflows or write your own instructions.',
    icon: '✍️',
  },
  {
    title: 'Run Workflows',
    description: 'Choose a workflow mode — parallel, pipeline, debate, or synthesis — and watch your agents collaborate in real time.',
    icon: '>',
  },
  {
    title: 'Keyboard Shortcuts',
    description: 'Press ⌘K for the command palette, ⌘Enter to run, ⌘D to decompose tasks. Speed up your workflow.',
    icon: '⌨️',
  },
  {
    title: "You're Ready",
    description: 'Start by selecting a few agents and trying a workflow template. The agents will handle the rest.',
    icon: '+',
  },
];

function shouldShow(): boolean {
  try {
    return !localStorage.getItem('agent-office-onboarded');
  } catch {
    return true;
  }
}

export function Onboarding({ onComplete }: OnboardingProps) {
  const [step, setStep] = useState(0);
  const [visible, setVisible] = useState(shouldShow);

  function handleComplete() {
    try {
      localStorage.setItem('agent-office-onboarded', 'true');
    } catch { /* noop */ }
    setVisible(false);
    onComplete();
  }

  if (!visible) return null;

  const current = STEPS[step];
  const isLast = step === STEPS.length - 1;

  return (
    <div className="onboard-overlay" role="dialog" aria-label="Onboarding">
      <div className="onboard-card">
        <div className="onboard-icon">{current.icon}</div>
        <h2 className="onboard-title">{current.title}</h2>
        <p className="onboard-desc">{current.description}</p>
        <div className="onboard-dots">
          {STEPS.map((_, i) => (
            <span key={i} className={`onboard-dot ${i === step ? 'active' : ''}`} />
          ))}
        </div>
        <div className="onboard-actions">
          <button className="onboard-skip" onClick={handleComplete}>Skip</button>
          <button
            className="onboard-next"
            onClick={() => isLast ? handleComplete() : setStep(s => s + 1)}
          >
            {isLast ? 'Get Started' : 'Next'}
          </button>
        </div>
      </div>
    </div>
  );
}
