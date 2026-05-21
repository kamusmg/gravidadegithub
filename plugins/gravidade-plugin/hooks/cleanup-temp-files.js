#!/usr/bin/env node
// Hook: SessionEnd
// Limpa arquivos temporarios criados por agentes durante a sessao
const fs = require('fs');
const path = require('path');
const os = require('os');

const homeDir = os.homedir();

function deletePattern(dir, pattern) {
  try {
    const files = fs.readdirSync(dir);
    for (const file of files) {
      if (pattern.test(file)) {
        fs.unlinkSync(path.join(dir, file));
      }
    }
  } catch (err) {
    // ignore
  }
}

// Delete temp files in home dir
deletePattern(homeDir, /^temp.*\.(json|txt)$/);
deletePattern(homeDir, /^scratch.*\.(md|txt)$/);
deletePattern(homeDir, /\.tmp$/);

// Delete temp files in /tmp (or tempdir)
const tempDir = os.tmpdir();
deletePattern(tempDir, /^claude-scratch-.*/);
deletePattern(tempDir, /^claude-work-.*/);
deletePattern(tempDir, /^jira-comment-.*/);
deletePattern(tempDir, /^antigravity-scratch-.*/);
deletePattern(tempDir, /^antigravity-work-.*/);

process.exit(0);
