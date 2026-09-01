import { useState, useRef, useEffect } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { PROJECT_TEMPLATES } from '../utils/projectTemplates';
import { useProjectBuilder } from '../hooks/useProjectBuilder';
import type { BuildProgress } from '../types/projectBuilder';

interface ProjectBuilderProps {
  provider: string;
}

export function ProjectBuilder({ provider }: ProjectBuilderProps) {
  const [prompt, setPrompt] = useState('');
  const [projectName, setProjectName] = useState('');
  const [selectedTemplate, setSelectedTemplate] = useState('react-vite');
  const { progress, isBuilding, build, cancel, reset } = useProjectBuilder();
  const logEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    logEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [progress?.logs.length]);

  async function handleBuild() {
    if (!prompt.trim() || !projectName.trim()) return;
    await build({
      projectName: projectName.trim().toLowerCase().replace(/\s+/g, '-'),
      templateId: selectedTemplate,
      prompt: prompt.trim(),
      provider,
    });
  }

  async function openProject() {
    if (progress?.projectPath) {
      await invoke('run_project_command', {
        projectPath: progress.projectPath,
        command: 'open',
        args: ['.'],
      }).catch(() => {});
    }
  }

  if (progress) {
    return <BuildView progress={progress} isBuilding={isBuilding} onCancel={cancel} onReset={reset} onOpen={openProject} logEndRef={logEndRef} />;
  }

  return (
    <div className="builder-container">
      <div className="builder-header">
        <h2>Build a Project</h2>
        <p className="text-sm text-muted">Describe what you want to build. The AI will generate all the code, install dependencies, and fix any errors.</p>
      </div>

      <div className="builder-form">
        <div className="form-group">
          <label>Project Name</label>
          <input
            type="text"
            value={projectName}
            onChange={e => setProjectName(e.target.value)}
            placeholder="my-awesome-app"
            className="setting-input"
          />
        </div>

        <div className="form-group">
          <label>Template</label>
          <div className="template-grid">
            {PROJECT_TEMPLATES.map(t => (
              <button
                key={t.id}
                className={`template-card ${selectedTemplate === t.id ? 'selected' : ''}`}
                onClick={() => setSelectedTemplate(t.id)}
              >
                <span className="template-icon">{t.icon}</span>
                <span className="template-name">{t.name}</span>
                <span className="template-desc">{t.description}</span>
              </button>
            ))}
          </div>
        </div>

        <div className="form-group">
          <label>What do you want to build?</label>
          <textarea
            value={prompt}
            onChange={e => setPrompt(e.target.value)}
            placeholder="A task management app with drag-and-drop, dark mode, and real-time collaboration..."
            className="setting-input builder-textarea"
            rows={6}
          />
        </div>

        <button
          className="btn btn-primary builder-build-btn"
          onClick={handleBuild}
          disabled={!prompt.trim() || !projectName.trim() || isBuilding}
        >
          {isBuilding ? 'Building...' : '🚀 Build Project'}
        </button>
      </div>
    </div>
  );
}

interface BuildViewProps {
  progress: BuildProgress;
  isBuilding: boolean;
  onCancel: () => void;
  onReset: () => void;
  onOpen: () => void;
  logEndRef: React.RefObject<HTMLDivElement | null>;
}

function BuildView({ progress, isBuilding, onCancel, onReset, onOpen, logEndRef }: BuildViewProps) {
  const statusColors: Record<string, string> = {
    idle: 'var(--text-4)',
    scaffolding: 'var(--accent)',
    generating: 'var(--yellow)',
    installing: 'var(--accent)',
    building: 'var(--accent)',
    fixing: 'var(--orange)',
    done: 'var(--green)',
    error: 'var(--red)',
  };

  const completedTasks = progress.tasks.filter(t => t.status === 'done').length;
  const totalTasks = progress.tasks.length;
  const progressPercent = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  return (
    <div className="builder-container">
      <div className="builder-header">
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <h2>Building: {progress.projectName}</h2>
            <p className="text-sm text-muted" style={{ color: statusColors[progress.status] }}>
              {progress.status.charAt(0).toUpperCase() + progress.status.slice(1)}...
            </p>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            {isBuilding && (
              <button className="btn btn-cancel" onClick={onCancel}>Cancel</button>
            )}
            {!isBuilding && progress.status === 'done' && (
              <>
                <button className="btn btn-secondary" onClick={onOpen}>Open Folder</button>
                <button className="btn btn-primary" onClick={onReset}>New Project</button>
              </>
            )}
            {!isBuilding && progress.status === 'error' && (
              <button className="btn btn-primary" onClick={onReset}>Try Again</button>
            )}
          </div>
        </div>

        {/* Progress bar */}
        <div className="builder-progress-bar">
          <div className="builder-progress-fill" style={{ width: `${progressPercent}%` }} />
        </div>
        <div className="builder-progress-text">
          {completedTasks}/{totalTasks} files generated
        </div>
      </div>

      {/* Task list */}
      {progress.tasks.length > 0 && (
        <div className="builder-tasks">
          {progress.tasks.map(task => (
            <div key={task.id} className={`builder-task ${task.status}`}>
              <span className="builder-task-icon">
                {task.status === 'done' && '✓'}
                {task.status === 'error' && '✗'}
                {task.status === 'generating' && '⟳'}
                {task.status === 'writing' && '↓'}
                {task.status === 'building' && '🔨'}
                {task.status === 'fixing' && '🔧'}
                {task.status === 'pending' && '○'}
              </span>
              <span className="builder-task-name">{task.name}</span>
              {task.retries > 0 && <span className="builder-task-retry">×{task.retries}</span>}
            </div>
          ))}
        </div>
      )}

      {/* Console output */}
      <div className="builder-console">
        <div className="builder-console-header">Output</div>
        <div className="builder-console-body">
          {progress.logs.map((entry, i) => (
            <div key={i} className={`builder-log builder-log-${entry.type}`}>
              <span className="builder-log-time">
                {new Date(entry.timestamp).toLocaleTimeString()}
              </span>
              <span className="builder-log-msg">{entry.message}</span>
            </div>
          ))}
          <div ref={logEndRef} />
        </div>
      </div>
    </div>
  );
}
