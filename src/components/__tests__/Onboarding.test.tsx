import { describe, it, expect, beforeEach } from 'vitest';
import { render, fireEvent } from '@testing-library/react';
import { Onboarding } from '../Onboarding';

describe('Onboarding', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('renders when not onboarded', () => {
    const { getByText } = render(<Onboarding onComplete={() => {}} />);
    expect(getByText('Welcome to Agent Office')).toBeTruthy();
  });

  it('does not render when already onboarded', () => {
    localStorage.setItem('agent-office-onboarded', 'true');
    const { container } = render(<Onboarding onComplete={() => {}} />);
    expect(container.innerHTML).toBe('');
  });

  it('calls onComplete when skip clicked', () => {
    let called = false;
    const { getByText } = render(<Onboarding onComplete={() => { called = true; }} />);
    fireEvent.click(getByText('Skip'));
    expect(called).toBe(true);
  });

  it('calls onComplete on last step', () => {
    let called = false;
    const { getAllByText, getByText } = render(<Onboarding onComplete={() => { called = true; }} />);
    for (let i = 0; i < 5; i++) {
      const btns = getAllByText('Next');
      fireEvent.click(btns[btns.length - 1]);
    }
    fireEvent.click(getByText('Get Started'));
    expect(called).toBe(true);
  });

  it('shows step dots', () => {
    const { container } = render(<Onboarding onComplete={() => {}} />);
    const dots = container.querySelectorAll('.onboard-dot');
    expect(dots.length).toBe(6);
  });
});
