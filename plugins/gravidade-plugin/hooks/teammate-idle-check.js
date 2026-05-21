#!/usr/bin/env node

/**
 * TeammateIdle hook — prevents teammates from going idle while pending tasks exist.
 * Exit code 2 = send feedback to teammate (keeps them working).
 * Exit code 0 = allow idle.
 */

let raw = '';
process.stdin.on('data', chunk => raw += chunk);
process.stdin.on('end', () => {
  let input;
  try { input = JSON.parse(raw); } catch { input = {}; }
  const teammateName = input.teammateName || input.teammate_name || 'teammate';
  const pendingTasks = input.pendingTasks || input.pending_tasks || 0;

  if (pendingTasks > 0) {
    process.stdout.write(
      `There are still ${pendingTasks} pending task(s). Pick up the next unassigned task before going idle.`
    );
    process.exit(2);
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

