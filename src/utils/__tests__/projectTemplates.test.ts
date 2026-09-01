import { describe, it, expect } from 'vitest';
import { PROJECT_TEMPLATES, getTemplate, scaffoldTemplate } from '../projectTemplates';

describe('Project Templates', () => {
  it('has all templates', () => {
    expect(PROJECT_TEMPLATES.length).toBe(4);
  });

  it('finds template by id', () => {
    expect(getTemplate('react-vite')).toBeTruthy();
    expect(getTemplate('nextjs')).toBeTruthy();
    expect(getTemplate('fullstack')).toBeTruthy();
    expect(getTemplate('blank')).toBeTruthy();
    expect(getTemplate('nonexistent')).toBeUndefined();
  });

  it('react-vite template has required files', () => {
    const t = getTemplate('react-vite')!;
    expect(t.files.length).toBeGreaterThan(0);
    const paths = t.files.map(f => f.path);
    expect(paths).toContain('package.json');
    expect(paths).toContain('src/App.tsx');
    expect(paths).toContain('index.html');
  });

  it('nextjs template has app directory structure', () => {
    const t = getTemplate('nextjs')!;
    const paths = t.files.map(f => f.path);
    expect(paths).toContain('src/app/layout.tsx');
    expect(paths).toContain('src/app/page.tsx');
  });

  it('fullstack template has server directory', () => {
    const t = getTemplate('fullstack')!;
    const paths = t.files.map(f => f.path);
    expect(paths).toContain('server/index.ts');
  });

  it('blank template has no files', () => {
    const t = getTemplate('blank')!;
    expect(t.files.length).toBe(0);
  });

  it('scaffoldTemplate replaces name placeholder', () => {
    const t = getTemplate('react-vite')!;
    const result = scaffoldTemplate(t, 'my-app');
    expect(result.length).toBe(t.files.length);
    const pkg = result.find(f => f.path === 'package.json');
    expect(pkg?.content).toContain('"my-app"');
    expect(pkg?.content).not.toContain('{{name}}');
  });

  it('scaffoldTemplate preserves non-name content', () => {
    const t = getTemplate('react-vite')!;
    const result = scaffoldTemplate(t, 'test');
    const viteConfig = result.find(f => f.path === 'vite.config.ts');
    expect(viteConfig?.content).toContain('vite');
  });
});
