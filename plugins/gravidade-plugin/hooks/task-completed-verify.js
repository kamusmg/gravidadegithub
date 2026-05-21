#!/usr/bin/env node

/**
 * TaskCompleted hook — verifies work quality before allowing task completion.
 * Exit code 2 = reject completion with feedback.
 * Exit code 0 = allow completion.
 */

const { execSync } = require('child_process');

let raw = '';
process.stdin.on('data', chunk => raw += chunk);
process.stdin.on('end', () => {
  let input;
  try { input = JSON.parse(raw); } catch { input = {}; }
  const taskTitle = input.taskTitle || input.task_title || 'unknown task';

// Check for uncommitted changes that might belong to this task
try {
  const status = execSync('git status --porcelain 2>/dev/null', {
    encoding: 'utf8',
    timeout: 5000,
  }).trim();

  const untracked = status
    .split('\n')
    .filter((line) => line.startsWith('??'))
    .length;

  if (untracked > 5) {
    process.stdout.write(
      `Found ${untracked} untracked files. Stage and commit your changes before marking "${taskTitle}" as complete.`
    );
    process.exit(2);
  }
} catch {
  // Not in a git repo or git not available — skip this check
}

// Check for TypeScript/lint errors in staged files
try {
  const diff = execSync('git diff --cached --name-only 2>/dev/null', {
    encoding: 'utf8',
    timeout: 5000,
  }).trim();

  const tsFiles = diff
    .split('\n')
    .filter((f) => /\.(ts|tsx)$/.test(f));

  if (tsFiles.length > 0) {
    try {
      execSync('npx tsc --noEmit 2>&1', {
        encoding: 'utf8',
        timeout: 30000,
      });
    } catch (tscError) {
      const errors = (tscError.stdout || '').split('\n').slice(0, 5).join('\n');
      process.stdout.write(
        `TypeScript errors found. Fix before completing "${taskTitle}":\n${errors}`
      );
      process.exit(2);
    }
  }
} catch {
  // No staged files or git not available — skip
}

process.exit(0);
});


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

