export interface ProjectTemplate {
  id: string;
  name: string;
  description: string;
  icon: string;
  files: TemplateFile[];
  installCmd: string;
  buildCmd: string;
  devCmd: string;
  testCmd?: string;
  lintCmd?: string;
}

export interface TemplateFile {
  path: string;
  content: string;
}

export interface BuildTask {
  id: string;
  name: string;
  status: 'pending' | 'generating' | 'writing' | 'building' | 'fixing' | 'done' | 'error';
  files: string[];
  error?: string;
  retries: number;
}

export interface BuildProgress {
  projectPath: string;
  projectName: string;
  template: string;
  tasks: BuildTask[];
  currentTaskIndex: number;
  logs: BuildLog[];
  status: 'idle' | 'scaffolding' | 'generating' | 'installing' | 'building' | 'fixing' | 'done' | 'error';
  error?: string;
}

export interface BuildLog {
  timestamp: string;
  type: 'info' | 'success' | 'error' | 'warning' | 'build';
  message: string;
}
