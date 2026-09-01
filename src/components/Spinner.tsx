import React from 'react';

interface SpinnerProps {
  size?: number;
  color?: string;
  label?: string;
}

export const Spinner = React.memo(function Spinner({ size = 20, color, label }: SpinnerProps) {
  return (
    <span className="spinner-wrapper" role="status" aria-label={label || 'Loading'}>
      <svg
        className="spinner"
        width={size}
        height={size}
        viewBox="0 0 24 24"
        fill="none"
        style={{ animation: 'spin-slow 1s linear infinite' }}
      >
        <circle cx="12" cy="12" r="10" stroke="currentColor" strokeOpacity={0.2} strokeWidth="3" />
        <path
          d="M12 2a10 10 0 0 1 10 10"
          stroke={color || 'var(--accent)'}
          strokeWidth="3"
          strokeLinecap="round"
        />
      </svg>
      {label && <span className="spinner-label">{label}</span>}
    </span>
  );
});
