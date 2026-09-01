#!/usr/bin/env node
/**
 * Import agency-agents markdown files → agents.json
 * Parses all .md files from the agency-agents repo and generates a unified registry.
 */

import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
import { join, basename } from 'path';

const AGENCY_DIR = process.argv[2] || '/tmp/agency-agents';
const OUTPUT = process.argv[3] || join(process.cwd(), 'public', 'agents.json');

// Office character mapping based on division
const DIVISION_TO_ROLE = {
  engineering: 'dev',
  design: 'designer',
  testing: 'qa',
  marketing: 'pm',
  sales: 'ops',
  product: 'pm',
  'project-management': 'pm',
  research: 'res',
  security: 'gate',
  strategy: 'arch',
  finance: 'pm',
  support: 'res',
  academic: 'res',
  specialized: 'dev',
  'game-development': 'dev',
  gis: 'res',
  healthcare: 'res',
  integrations: 'ops',
  'paid-media': 'pm',
  'spatial-computing': 'dev',
};

const DIVISION_EMOJI = {
  engineering: '🔧',
  design: '🎨',
  testing: '🔍',
  marketing: '📢',
  sales: '💼',
  product: '📊',
  'project-management': '📋',
  research: '📚',
  security: '🛡️',
  strategy: '🧭',
  finance: '💰',
  support: '🛟',
  academic: '🎓',
  specialized: '⚡',
  'game-development': '🎮',
  gis: '🌍',
  healthcare: '🏥',
  integrations: '🔗',
  'paid-media': '💸',
  'spatial-computing': '🥽',
};

function findMarkdownFiles(dir) {
  const results = [];
  for (const entry of readdirSync(dir)) {
    const fullPath = join(dir, entry);
    const stat = statSync(fullPath);
    if (stat.isDirectory() && !entry.startsWith('.') && entry !== 'scripts' && entry !== 'examples' && entry !== '.github') {
      results.push(...findMarkdownFiles(fullPath));
    } else if (entry.endsWith('.md') && entry !== 'README.md' && entry !== 'CONTRIBUTING.md' && entry !== 'CONTRIBUTING_zh-CN.md' && entry !== 'SECURITY.md') {
      results.push(fullPath);
    }
  }
  return results;
}

function parseAgentMd(content, filePath) {
  const lines = content.split('\n');
  
  // Extract title (first # heading)
  let name = '';
  let description = '';
  for (const line of lines) {
    if (line.startsWith('# ') && !name) {
      name = line.replace(/^#\s+/, '').replace(/[^\x00-\x7F]/g, '').trim();
    }
    if (line.startsWith('**Purpose**') || line.startsWith('## Purpose') || line.startsWith('## Mission')) {
      description = lines.indexOf(line) + 1 < lines.length ? lines[lines.indexOf(line) + 1].trim() : '';
    }
  }

  // Fallback: use first non-empty line after title
  if (!description) {
    for (const line of lines) {
      if (line.trim() && !line.startsWith('#') && !line.startsWith('---') && !line.startsWith('**') && line.trim().length > 20) {
        description = line.trim();
        break;
      }
    }
  }

  // Extract the full content as system prompt (skip frontmatter)
  let systemPrompt = content;
  if (content.startsWith('---')) {
    const endIdx = content.indexOf('---', 3);
    if (endIdx > 0) {
      systemPrompt = content.slice(endIdx + 3).trim();
    }
  }

  // Determine division from path
  const pathParts = filePath.replace(AGENCY_DIR + '/', '').split('/');
  const division = pathParts[0] || 'engineering';

  // Generate ID from filename
  const id = basename(filePath, '.md');

  return {
    id,
    name: name || id.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
    division,
    description: description.slice(0, 200),
    systemPrompt,
    officeRole: DIVISION_TO_ROLE[division] || 'dev',
    emoji: DIVISION_EMOJI[division] || '🤖',
    tags: [],
  };
}

// Main
console.log(`Scanning ${AGENCY_DIR}...`);
const mdFiles = findMarkdownFiles(AGENCY_DIR);
console.log(`Found ${mdFiles.length} agent files`);

const agents = mdFiles.map(file => {
  const content = readFileSync(file, 'utf-8');
  return parseAgentMd(content, file);
}).filter(a => a.systemPrompt.length > 50);

// Sort by division, then name
agents.sort((a, b) => a.division.localeCompare(b.division) || a.name.localeCompare(b.name));

console.log(`Parsed ${agents.length} agents`);

// Write output
writeFileSync(OUTPUT, JSON.stringify({ agents, generatedAt: new Date().toISOString() }, null, 2));
console.log(`Wrote ${OUTPUT}`);
console.log(`Divisions: ${[...new Set(agents.map(a => a.division))].join(', ')}`);
