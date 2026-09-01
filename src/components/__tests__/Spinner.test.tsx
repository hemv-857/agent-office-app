import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/react';
import { Spinner } from '../Spinner';

describe('Spinner', () => {
  it('renders with default props', () => {
    const { container } = render(<Spinner />);
    expect(container.querySelector('.spinner')).toBeTruthy();
  });

  it('renders with custom size', () => {
    const { container } = render(<Spinner size={40} />);
    const svg = container.querySelector('svg');
    expect(svg?.getAttribute('width')).toBe('40');
    expect(svg?.getAttribute('height')).toBe('40');
  });

  it('renders with label', () => {
    const { getByText } = render(<Spinner label="Loading data…" />);
    expect(getByText('Loading data…')).toBeTruthy();
  });

  it('has correct aria-label', () => {
    const { getByRole } = render(<Spinner label="Processing" />);
    expect(getByRole('status')).toBeTruthy();
  });

  it('renders without label', () => {
    const { container } = render(<Spinner />);
    expect(container.querySelector('.spinner-label')).toBeFalsy();
  });

  it('applies custom color', () => {
    const { container } = render(<Spinner color="#ff0000" />);
    expect(container.querySelector('svg')).toBeTruthy();
  });
});
