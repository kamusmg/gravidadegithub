#!/usr/bin/env node
// PostToolUse (Edit|Write): typecheck TS/JS files after edit.
// Port of typecheck-after-edit.sh — fixes Windows dirname infinite loop,
// bounds project-root walk, and uses hard timeout.
// Exit 0 always (advisory only — never blocks writes).

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const CODE_EXTS = new Set(['.ts', '.tsx', '.js', '.jsx']);
const MAX_WALK_DEPTH = 12;
const TSC_TIMEOUT_MS = 3000;

let raw = '';
process.stdin.on('data', (c) => (raw += c));
process.stdin.on('end', () => {
  let filePath;
  try {
    const inputParsed = JSON.parse(raw);
    filePath = getToolInputProperty(inputParsed, ['TargetFile', 'targetFile', 'file_path', 'filePath']);
  } catch {
    process.exit(0);
  }
  if (!filePath) process.exit(0);

  const ext = path.extname(filePath).toLowerCase();
  if (!CODE_EXTS.has(ext)) process.exit(0);

  const projectDir = findProjectRoot(path.dirname(filePath));
  if (!projectDir) process.exit(0);

  const tscBin = path.join(
    projectDir,
    'node_modules',
    '.bin',
    process.platform === 'win32' ? 'tsc.cmd' : 'tsc',
  );
  if (!fs.existsSync(tscBin)) process.exit(0);

  const result = spawnSync(tscBin, ['--noEmit', '--incremental', '--pretty'], {
    cwd: projectDir,
    timeout: TSC_TIMEOUT_MS,
    encoding: 'utf8',
    shell: process.platform === 'win32',
  });

  if (result.signal === 'SIGTERM' || result.error?.code === 'ETIMEDOUT') {
    // tsc too slow — skip silently rather than holding up the edit.
    process.exit(0);
  }

  if (result.status !== 0) {
    const output = (result.stdout || '') + (result.stderr || '');
    const trimmed = output.split('\n').slice(0, 30).join('\n');
    if (trimmed.trim()) process.stderr.write(trimmed + '\n');
  }
  process.exit(0);
});

function findProjectRoot(startDir) {
  let dir = startDir;
  for (let i = 0; i < MAX_WALK_DEPTH; i++) {
    if (fs.existsSync(path.join(dir, 'tsconfig.json'))) return dir;
    const parent = path.dirname(dir);
    if (parent === dir) return null; // reached filesystem root or a Windows drive stub like "C:"
    dir = parent;
  }
  return null;
}


// Robust helper for Antigravity & Claude compatibility
function getToolInputProperty(inputObj, keys) {
  const toolInput = inputObj.toolInput || inputObj.tool_input || inputObj || {};
  for (const k of keys) {
    if (toolInput[k] !== undefined) return toolInput[k];
    for (const key of Object.keys(toolInput)) {
      if (key.toLowerCase() === k.toLowerCase()) {
        return toolInput[key];
      }
    }
  }
  return undefined;
}

function getToolResponse(inputObj) {
  return inputObj.toolResponse || inputObj.tool_response || inputObj.output || inputObj.result || "";
}

