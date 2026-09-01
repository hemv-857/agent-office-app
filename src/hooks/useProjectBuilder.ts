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
  const userPrompt = existingContent
    ? `Fix the following file that has errors. The file is: ${filePath}
Context about the project: ${projectContext}
User's original request: ${prompt}

Current file content with errors:
${existingContent}

Fix the errors and return the complete corrected file.`
    : `Generate a file for a project.
File path: ${filePath}
Project context: ${projectContext}
User's original request: ${prompt}

Generate the complete file content.`;

  const result = await invoke<string>('execute_task', {
    request: {
      prompt: userPrompt,
      agent_ids: ['assistant'],
      provider,
      model,
      temperature: 0.3,
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
  const userPrompt = `User wants to build: ${prompt}
Template: ${templateId}

List all files that need to be created for this project. Be thorough — include every component, utility, type file, config, etc.`;

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

      // Step 2: Scaffold template files (if any)
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
          emit(log(progress, 'success', `✓ ${filePath}`));
        } catch (err) {
          progress = updateTask(progress, task.id, { status: 'error', error: String(err) });
          emit(log(progress, 'error', `✗ ${filePath}: ${err}`));
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
