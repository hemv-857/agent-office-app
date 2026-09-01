const ENTITY_MAP: Record<string, string> = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#x27;',
  '/': '&#x2F;',
};

export function escapeHtml(str: string): string {
  return str.replace(/[&<>"'/]/g, c => ENTITY_MAP[c] || c);
}

export function sanitizeInput(input: string): string {
  return input
    .replace(/[<>]/g, '')
    .replace(/javascript:/gi, '')
    .replace(/on\w+\s*=/gi, '')
    .trim();
}

export function containsPromptInjection(text: string): boolean {
  const patterns = [
    /ignore\s+(all\s+)?previous\s+instructions/i,
    /you\s+are\s+now\s+(a|an)\s+/i,
    /system\s*:\s*/i,
    /\[INST\]/i,
    /<\|im_start\|>/i,
    /<<SYS>>/i,
    /forget\s+(everything|all|your\s+instructions)/i,
    /new\s+instructions?\s*:/i,
    /override\s+(your|the)\s+(instructions?|rules?|system\s+prompt)/i,
  ];
  return patterns.some(p => p.test(text));
}

export function truncate(str: string, maxLen: number): string {
  if (str.length <= maxLen) return str;
  return str.slice(0, maxLen - 3) + '...';
}

export function sanitizeFilename(name: string): string {
  return name
    .replace(/[^a-zA-Z0-9._-]/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
    .replace(/\.-/g, '.')
    .replace(/-\./g, '.')
    .slice(0, 100);
}

export function redactSecrets(text: string): string {
  return text
    .replace(/sk-ant-[a-zA-Z0-9-]+/g, '[REDACTED_ANTHROPIC_KEY]')
    .replace(/sk-[a-zA-Z0-9_-]{20,}/g, '[REDACTED_OPENAI_KEY]')
    .replace(/ghp_[a-zA-Z0-9]+/g, '[REDACTED_GITHUB_TOKEN]')
    .replace(/xoxb-[a-zA-Z0-9-]+/g, '[REDACTED_SLACK_TOKEN]')
    .replace(/AKIA[A-Z0-9]{16}/g, '[REDACTED_AWS_KEY]');
}
