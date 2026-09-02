import React from 'react';

interface Props {
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
  errorInfo: React.ErrorInfo | null;
}

export class ErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null, errorInfo: null };
  }

  static getDerivedStateFromError(error: Error): Partial<State> {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Agent Office error:', error, errorInfo);
    this.setState({ errorInfo });
  }

  handleCopyError = () => {
    const { error, errorInfo } = this.state;
    const text = `Error: ${error?.message}\n\nStack: ${error?.stack}\n\nComponent Stack: ${errorInfo?.componentStack}`;
    navigator.clipboard.writeText(text).catch(() => {});
  };

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div style={{
            padding: 24,
            fontFamily: 'Inter, system-ui, sans-serif',
            background: '#0f0f11',
            color: '#fafafa',
            height: '100vh',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 16,
          }}>
            <div style={{ fontSize: 48 }}></div>
            <h2 style={{ margin: 0, fontSize: 20 }}>Something went wrong</h2>
            <p style={{ color: '#a1a1aa', maxWidth: 460, textAlign: 'center', fontSize: 14, lineHeight: 1.5 }}>
              {this.state.error?.message || 'An unexpected error occurred'}
            </p>
            <div style={{ display: 'flex', gap: 8 }}>
              <button
                onClick={() => window.location.reload()}
                style={{
                  padding: '8px 20px',
                  background: '#6391ff',
                  color: '#fff',
                  border: 'none',
                  borderRadius: 8,
                  cursor: 'pointer',
                  fontSize: 13,
                  fontWeight: 600,
                }}
              >
                Reload App
              </button>
              <button
                onClick={this.handleCopyError}
                style={{
                  padding: '8px 20px',
                  background: '#27272a',
                  color: '#a1a1aa',
                  border: '1px solid rgba(255,255,255,0.06)',
                  borderRadius: 8,
                  cursor: 'pointer',
                  fontSize: 13,
                }}
              >
                Copy Error
              </button>
            </div>
            {this.state.error?.stack && (
              <pre style={{
                marginTop: 16,
                padding: 12,
                background: '#18181b',
                border: '1px solid rgba(255,255,255,0.06)',
                borderRadius: 8,
                fontSize: 11,
                color: '#71717a',
                maxWidth: 600,
                maxHeight: 200,
                overflow: 'auto',
                whiteSpace: 'pre-wrap',
                wordBreak: 'break-word',
              }}>
                {this.state.error.stack}
              </pre>
            )}
          </div>
        )
      );
    }

    return this.props.children;
  }
}
