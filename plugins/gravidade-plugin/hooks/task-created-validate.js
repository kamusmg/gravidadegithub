#!/usr/bin/env node

/**
 * TaskCreated hook — validates tasks have sufficient description before creation.
 * Exit code 2 = reject creation with feedback.
 * Exit code 0 = allow creation.
 */

let raw = '';
process.stdin.on('data', chunk => raw += chunk);
process.stdin.on('end', () => {
  let input;
  try { input = JSON.parse(raw); } catch { input = {}; }
  const title = (input.taskTitle || input.task_title || '').trim();
  const description = (input.taskDescription || input.task_description || '').trim();

  if (!title || title.length < 5) {
    process.stdout.write(
      'Task title is too short. Provide a clear, descriptive title (min 5 chars) so teammates understand the scope.'
    );
    process.exit(2);
  }

  if (!description || description.length < 20) {
    process.stdout.write(
      'Task description is too brief. Include: what to do, which files/modules are involved, and acceptance criteria.'
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

