import type { CustomAgentForm } from '../types';

export const ROLES = ['dev', 'qa', 'ops', 'arch', 'pm', 'res', 'gate', 'designer'] as const;

export const ROLE_COLORS: Record<string, string> = {
  dev: '#E8927C',
  qa: '#7CA7E8',
  ops: '#A7E87C',
  arch: '#E8D47C',
  pm: '#D47CE8',
  res: '#7CE8D4',
  gate: '#E87CA7',
  designer: '#E87CE8',
};

export const TEMPLATES = [
  { label: 'Code Review', prompt: 'Review this code for bugs, performance issues, and best practices. Suggest improvements.' },
  { label: 'Bug Analysis', prompt: 'Analyze this bug report. Identify root cause, affected components, and suggest a fix.' },
  { label: 'Architecture', prompt: 'Evaluate this architecture decision. Consider scalability, maintainability, and trade-offs.' },
  { label: 'Test Plan', prompt: 'Create a comprehensive test plan for this feature. Include unit, integration, and edge cases.' },
  { label: 'Documentation', prompt: 'Write clear documentation for this code/feature. Include usage examples and edge cases.' },
  { label: 'Security Audit', prompt: 'Perform a security review. Check for injection, auth flaws, data exposure, and OWASP Top 10.' },
];

export interface WorkflowTemplate {
  id: string;
  label: string;
  icon: string;
  prompt: string;
  agentRoles: string[];
  workflowMode: string;
  description: string;
}

export const WORKFLOW_TEMPLATES: WorkflowTemplate[] = [
  {
    id: 'full-review',
    label: 'Full Code Review',
    icon: '🔍',
    prompt: 'Perform a comprehensive code review. Check for bugs, security issues, performance, and maintainability.',
    agentRoles: ['dev', 'qa', 'arch', 'gate'],
    workflowMode: 'review',
    description: 'Dev reviews, QA tests, Architect evaluates design, Gatekeeper approves',
  },
  {
    id: 'feature-dev',
    label: 'Feature Development',
    icon: '🚀',
    prompt: 'Design and implement this feature. Break it into tasks, write code, create tests, and document it.',
    agentRoles: ['pm', 'arch', 'dev', 'qa'],
    workflowMode: 'pipeline',
    description: 'PM specs → Architect designs → Dev implements → QA validates',
  },
  {
    id: 'security-pentest',
    label: 'Security Pentest',
    icon: '🛡',
    prompt: 'Perform a security penetration test. Identify vulnerabilities, exploit paths, and remediation steps.',
    agentRoles: ['res', 'dev', 'gate'],
    workflowMode: 'debate',
    description: 'Researcher finds vulns, Dev fixes, Gatekeeper validates',
  },
  {
    id: 'performance-opt',
    label: 'Performance Optimization',
    icon: '⚡',
    prompt: 'Profile and optimize this code. Identify bottlenecks, suggest improvements, measure impact.',
    agentRoles: ['dev', 'ops', 'qa'],
    workflowMode: 'pipeline',
    description: 'Dev optimizes, Ops measures, QA validates no regressions',
  },
  {
    id: 'api-design',
    label: 'API Design Review',
    icon: '📐',
    prompt: 'Review this API design. Check REST conventions, error handling, versioning, and documentation.',
    agentRoles: ['arch', 'dev', 'res'],
    workflowMode: 'synthesis',
    description: 'Architect, Dev, and Researcher synthesize a consensus API design',
  },
  {
    id: 'incident-response',
    label: 'Incident Response',
    icon: '🚨',
    prompt: 'Analyze this incident. Determine root cause, impact, and create a response plan with prevention steps.',
    agentRoles: ['ops', 'dev', 'pm'],
    workflowMode: 'parallel',
    description: 'Ops investigates, Dev fixes, PM coordinates response',
  },
  {
    id: 'doc-sprint',
    label: 'Documentation Sprint',
    icon: '📝',
    prompt: 'Write comprehensive documentation for this codebase. Include API docs, architecture overview, and getting started guide.',
    agentRoles: ['res', 'dev', 'designer'],
    workflowMode: 'parallel',
    description: 'Researcher gathers info, Dev writes technical docs, Designer formats',
  },
  {
    id: 'refactor-plan',
    label: 'Refactoring Plan',
    icon: '♻',
    prompt: 'Analyze this code for refactoring opportunities. Prioritize by impact, estimate effort, and create a phased plan.',
    agentRoles: ['arch', 'dev', 'qa'],
    workflowMode: 'pipeline-approval',
    description: 'Architect plans → Dev estimates → QA validates approach',
  },
  {
    id: 'db-migration',
    label: 'Database Migration',
    icon: '🗄',
    prompt: 'Design and review this database migration. Check schema changes, data integrity, rollback strategy, and performance impact.',
    agentRoles: ['arch', 'dev', 'ops'],
    workflowMode: 'pipeline',
    description: 'Architect designs schema → Dev writes migration → Ops validates rollback',
  },
  {
    id: 'ui-ux-review',
    label: 'UI/UX Review',
    icon: '🎨',
    prompt: 'Review this UI for usability, accessibility (WCAG), visual consistency, and responsive design. Suggest improvements.',
    agentRoles: ['designer', 'dev', 'qa'],
    workflowMode: 'review',
    description: 'Designer reviews UX, Dev checks implementation, QA validates accessibility',
  },
  {
    id: 'release-checklist',
    label: 'Release Checklist',
    icon: '📦',
    prompt: 'Prepare a release checklist. Verify tests pass, docs updated, changelog written, version bumped, and rollback plan ready.',
    agentRoles: ['qa', 'ops', 'pm'],
    workflowMode: 'parallel',
    description: 'QA verifies tests, Ops checks deployment, PM reviews release notes',
  },
  {
    id: 'tech-debt',
    label: 'Tech Debt Assessment',
    icon: '🧹',
    prompt: 'Identify and categorize tech debt. Estimate effort, prioritize by business impact, and create a remediation plan.',
    agentRoles: ['arch', 'dev', 'pm'],
    workflowMode: 'synthesis',
    description: 'Architect identifies, Dev estimates effort, PM prioritizes by business value',
  },
  {
    id: 'load-test',
    label: 'Load Testing Plan',
    icon: '📈',
    prompt: 'Design a load testing strategy. Define scenarios, expected throughput, latency targets, and monitoring setup.',
    agentRoles: ['ops', 'dev', 'res'],
    workflowMode: 'parallel',
    description: 'Ops designs infra, Dev writes tests, Research benchmarks',
  },
  {
    id: 'api-migration',
    label: 'API Version Migration',
    icon: '🔄',
    prompt: 'Plan an API version migration. Identify breaking changes, create migration guide, and implement backward compatibility.',
    agentRoles: ['arch', 'dev', 'pm'],
    workflowMode: 'pipeline',
    description: 'Architect plans versions → Dev implements compat layer → PM writes migration guide',
  },
  {
    id: 'code-consolidation',
    label: 'Code Consolidation',
    icon: '🔗',
    prompt: 'Find duplicate code across the codebase. Consolidate into shared utilities, reduce maintenance burden.',
    agentRoles: ['dev', 'arch', 'qa'],
    workflowMode: 'pipeline-approval',
    description: 'Dev finds duplicates → Architect designs shared utils → QA validates no regressions',
  },
];

export const STORAGE_KEYS = {
  seats: 'agent-office-seats',
  division: 'agent-office-division',
  provider: 'agent-office-provider',
  compact: 'agent-office-compact',
  budget: 'agent-office-budget',
  favorites: 'agent-office-favorites',
  theme: 'agent-office-theme',
  customAgents: 'agent-office-custom-agents',
  groups: 'agent-office-groups',
  presets: 'agent-office-presets',
  bookmarks: 'agent-office-bookmarks',
  prompts: 'agent-office-prompts',
  sidebarSections: 'agent-office-sidebar-sections',
  costHistory: 'agent-office-cost-history',
  leaderboard: 'agent-office-leaderboard',
  budgetConfig: 'agent-office-budget-config',
} as const;

export const DEFAULT_CUSTOM_AGENT: CustomAgentForm = {
  name: '',
  division: 'custom',
  description: '',
  office_role: 'dev',
  emoji: '🤖',
  system_prompt: '',
};

export const ROLE_MAP: Record<string, string> = {
  dev: 'dev',
  qa: 'qa',
  ops: 'ops',
  arch: 'arch',
  pm: 'pm',
  res: 'res',
  gate: 'gate',
  design: 'designer',
};
