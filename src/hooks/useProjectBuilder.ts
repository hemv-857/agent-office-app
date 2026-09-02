import { useState, useCallback, useRef } from 'react';
import { invoke } from '@tauri-apps/api/core';
import type { BuildProgress, BuildTask, BuildLog } from '../types/projectBuilder';
import { getTemplate, scaffoldTemplate } from '../utils/projectTemplates';

interface BuildOptions {
  projectName: string;
  templateId: string;
  prompt: string;
  provider: string;
  model?: string;
  onProgress?: (progress: BuildProgress) => void;
}

function log(progress: BuildProgress, type: BuildLog['type'], message: string): BuildProgress {
  return {
    ...progress,
    logs: [...progress.logs, { timestamp: new Date().toISOString(), type, message }],
  };
}

function updateTask(progress: BuildProgress, taskId: string, updates: Partial<BuildTask>): BuildProgress {
  return {
    ...progress,
    tasks: progress.tasks.map(t => t.id === taskId ? { ...t, ...updates } : t),
  };
}

async function generateCodeForFile(
  prompt: string,
  filePath: string,
  existingContent: string | null,
  projectContext: string,
  provider: string,
  model: string,
): Promise<string> {
  const fileExt = filePath.split('.').pop() || '';
  const isConfig = ['json', 'ts', 'js', 'config'].some(e => filePath.includes(e));
  const isComponent = filePath.includes('Component') || filePath.includes('.tsx') || filePath.includes('.jsx');

  const systemPrompt = `You are a senior software engineer generating production-quality code.
Rules:
- Output ONLY the file content. No explanations, no markdown fences, no backticks, no comments about what you're doing.
- The code must be complete, working, and follow modern best practices.
- Use TypeScript strict mode, proper error handling, and clean imports.
- For React components: use functional components, hooks, proper prop types.
- For config files: include all necessary options with sensible defaults.
- Never leave TODO comments or placeholder code.`;

  const userPrompt = existingContent
    ? `Fix the file "${filePath}" which has build errors.

Error context: ${projectContext}

User's original request: ${prompt}

Current broken file:
${existingContent}

Return the complete fixed file.`
    : `Generate the file "${filePath}" for this project.

Project context: ${projectContext}
File type: ${fileExt}
${isComponent ? 'This is a React component — use functional components with hooks.' : ''}
${isConfig ? 'This is a config file — include all necessary options.' : ''}

User's original request: ${prompt}

Generate the complete file content now.`;

  const result = await invoke<string>('execute_task', {
    request: {
      prompt: `${systemPrompt}\n\n${userPrompt}`,
      agent_ids: ['assistant'],
      provider,
      model,
      temperature: 0.2,
    },
  });

  // Strip markdown fences if present
  let cleaned = result.trim();
  if (cleaned.startsWith('```')) {
    cleaned = cleaned.replace(/^```(?:\w+)?\n?/, '').replace(/\n?```$/, '');
  }
  return cleaned;
}

async function generateFileList(
  prompt: string,
  templateId: string,
  provider: string,
  model: string,
): Promise<string[]> {
  const userPrompt = `You are a senior architect planning a ${templateId} project.

User wants to build: ${prompt}

Plan the complete file structure. Rules:
- Include ALL files needed: components, pages, hooks, utils, types, styles, configs, tests
- Use standard ${templateId} conventions (e.g., src/ for React, app/ for Next.js)
- Group related components in directories
- Include type definitions for all data structures
- Include utility functions for common operations
- Include test files for critical components
- Keep files focused (one component per file)

Return a JSON array of file paths. Example:
["src/App.tsx", "src/components/Header.tsx", "src/hooks/useApi.ts", "src/types/index.ts"]`;

  const result = await invoke<string>('execute_task', {
    request: {
      prompt: userPrompt,
      agent_ids: ['assistant'],
      provider,
      model,
      temperature: 0.2,
    },
  });

  let cleaned = result.trim();
  if (cleaned.startsWith('```')) {
    cleaned = cleaned.replace(/^```(?:\w+)?\n?/, '').replace(/\n?```$/, '');
  }

  try {
    return JSON.parse(cleaned);
  } catch {
    // Fallback: extract paths from text
    const matches = cleaned.match(/(?:src|public|server|tests)\/[\w\-./]+\.\w+/g);
    return matches || ['src/App.tsx'];
  }
}

async function tryBuild(
  projectPath: string,
  buildCmd: string,
): Promise<{ success: boolean; error: string; output: string }> {
  const [cmd, ...args] = buildCmd.split(' ');
  const result = await invoke<{ exit_code: number; stdout: string; stderr: string }>(
    'run_project_command',
    { projectPath, command: cmd, args },
  );

  return {
    success: result.exit_code === 0,
    error: result.stderr,
    output: result.stdout + result.stderr,
  };
}

export function useProjectBuilder() {
  const [progress, setProgress] = useState<BuildProgress | null>(null);
  const [isBuilding, setIsBuilding] = useState(false);
  const abortRef = useRef(false);

  const build = useCallback(async (options: BuildOptions) => {
    const { projectName, templateId, prompt, provider, model, onProgress } = options;
    const template = getTemplate(templateId);
    if (!template) throw new Error(`Template "${templateId}" not found`);

    abortRef.current = false;
    setIsBuilding(true);

    let progress: BuildProgress = {
      projectPath: '',
      projectName,
      template: templateId,
      tasks: [],
      currentTaskIndex: 0,
      logs: [],
      status: 'scaffolding',
    };

    const emit = (p: BuildProgress) => {
      progress = p;
      setProgress(p);
      onProgress?.(p);
    };

    try {
      // Step 1: Create project directory
      emit(log(progress, 'info', `Creating project "${projectName}"...`));
      const result = await invoke<{ project_path: string; files_created: string[] }>(
        'create_project_dir',
        { name: projectName },
      );
      progress.projectPath = result.project_path;
      emit(log(progress, 'success', `Project created at ${result.project_path}`));

      // Step 2: Initialize git
      emit(log(progress, 'info', 'Initializing git repository...'));
      await invoke('run_project_command', {
        projectPath: progress.projectPath,
        command: 'git',
        args: ['init'],
      }).catch(() => {});

      // Step 3: Scaffold template files (if any)
      if (template.files.length > 0) {
        emit(log(progress, 'info', `Scaffolding ${template.name} template...`));
        const scaffolded = scaffoldTemplate(template, projectName);
        await invoke<string[]>('batch_write_files', {
          projectPath: progress.projectPath,
          files: scaffolded,
        });
        emit(log(progress, 'success', `Scaffolded ${scaffolded.length} template files`));
      }

      // Step 3: Generate file list from prompt
      emit(log(progress, 'info', 'Planning project structure...'));
      const fileList = await generateFileList(prompt, templateId, provider, model || 'claude-sonnet-4-20250514');
      emit(log(progress, 'info', `Planned ${fileList.length} files to generate`));

      // Step 4: Create tasks for each file group
      const tasks: BuildTask[] = fileList.map((path, i) => ({
        id: `task-${i}`,
        name: path,
        status: 'pending' as const,
        files: [path],
        retries: 0,
      }));
      progress.tasks = tasks;
      emit(progress);

      // Step 5: Generate and write each file
      for (let i = 0; i < tasks.length; i++) {
        if (abortRef.current) {
          emit(log(progress, 'warning', 'Build cancelled'));
          break;
        }

        progress.currentTaskIndex = i;
        const task = tasks[i];
        const filePath = task.files[0];

        progress = updateTask(progress, task.id, { status: 'generating' });
        emit(log(progress, 'info', `Generating ${filePath}...`));

        try {
          const content = await generateCodeForFile(
            prompt, filePath, null,
            `Template: ${templateId}, Project: ${projectName}`,
            provider, model || 'claude-sonnet-4-20250514',
          );

          progress = updateTask(progress, task.id, { status: 'writing' });
          emit(progress);

          await invoke('write_project_file', {
            projectPath: progress.projectPath,
            filePath,
            content,
          });

          progress = updateTask(progress, task.id, { status: 'done' });
          emit(log(progress, 'success', ` ${filePath}`));
        } catch (err) {
          progress = updateTask(progress, task.id, { status: 'error', error: String(err) });
          emit(log(progress, 'error', ` ${filePath}: ${err}`));
        }
      }

      // Step 6: Install dependencies
      progress.status = 'installing';
      emit(log(progress, 'info', 'Installing dependencies...'));
      const installResult = await tryBuild(progress.projectPath, template.installCmd + ' install');
      if (!installResult.success) {
        emit(log(progress, 'error', `Install failed: ${installResult.error}`));
        progress.status = 'error';
        progress.error = installResult.error;
        emit(progress);
        return;
      }
      emit(log(progress, 'success', 'Dependencies installed'));

      // Step 7: Build and fix loop
      progress.status = 'building';
      emit(log(progress, 'info', 'Building project...'));
      let buildResult = await tryBuild(progress.projectPath, template.buildCmd);
      let buildAttempts = 0;
      const MAX_BUILD_ATTEMPTS = 3;

      while (!buildResult.success && buildAttempts < MAX_BUILD_ATTEMPTS) {
        if (abortRef.current) break;

        buildAttempts++;
        progress.status = 'fixing';
        emit(log(progress, 'warning', `Build failed (attempt ${buildAttempts}/${MAX_BUILD_ATTEMPTS})`));
        emit(log(progress, 'error', buildResult.error.slice(0, 500)));
        emit(progress);

        // Try to fix the errors
        emit(log(progress, 'info', 'Attempting to fix build errors...'));
        const files = await invoke<string[]>('list_project_files', { projectPath: progress.projectPath });

        // Find which file likely has the error
        const errorMatch = buildResult.error.match(/(?:src|server)\/[\w\-./]+\.\w+:\d+:\d+/);
        const errorFile = errorMatch ? errorMatch[0].split(':')[0] : files[0];

        try {
          const existing = await invoke<string>('read_project_file', {
            projectPath: progress.projectPath,
            filePath: errorFile,
          });

          const fixed = await generateCodeForFile(
            prompt, errorFile, existing,
            `Build error: ${buildResult.error.slice(0, 1000)}`,
            provider, model || 'claude-sonnet-4-20250514',
          );

          await invoke('write_project_file', {
            projectPath: progress.projectPath,
            filePath: errorFile,
            content: fixed,
          });

          emit(log(progress, 'success', `Fixed ${errorFile}`));
        } catch (fixErr) {
          emit(log(progress, 'error', `Fix failed: ${fixErr}`));
        }

        // Retry build
        emit(log(progress, 'info', 'Retrying build...'));
        buildResult = await tryBuild(progress.projectPath, template.buildCmd);
      }

      if (buildResult.success) {
        // Step 8: Run quality gates (lint, tests)
        if (template.lintCmd) {
          emit(log(progress, 'info', 'Running linter...'));
          const lintResult = await tryBuild(progress.projectPath, template.lintCmd);
          if (lintResult.success) {
            emit(log(progress, 'success', 'Lint passed'));
          } else {
            emit(log(progress, 'warning', `Lint issues: ${lintResult.error.slice(0, 300)}`));
          }
        }

        if (template.testCmd) {
          emit(log(progress, 'info', 'Running tests...'));
          const testResult = await tryBuild(progress.projectPath, template.testCmd);
          if (testResult.success) {
            emit(log(progress, 'success', 'Tests passed'));
          } else {
            emit(log(progress, 'warning', `Tests failed: ${testResult.error.slice(0, 300)}`));
          }
        }

        progress.status = 'done';
        emit(log(progress, 'success', 'Build succeeded! Project is ready.'));
      } else {
        progress.status = 'error';
        progress.error = buildResult.error;
        emit(log(progress, 'error', 'Build failed after maximum retries'));
      }

      emit(progress);
    } catch (err) {
      progress.status = 'error';
      progress.error = String(err);
      emit(log(progress, 'error', `Build failed: ${err}`));
      emit(progress);
    } finally {
      setIsBuilding(false);
    }
  }, []);

  const cancel = useCallback(() => {
    abortRef.current = true;
  }, []);

  const reset = useCallback(() => {
    setProgress(null);
    setIsBuilding(false);
  }, []);

  return { progress, isBuilding, build, cancel, reset };
}
