---
name: command-investigate
description: >
  Trigger this skill when the user types /investigate or asks to perform the action: Systematic discovery through focused questions before planning
---

# Investigation Protocol

Before planning or implementing, investigate: $ARGUMENTS

## Process

### 1. Initial Discovery
Ask 3-5 focused questions about:
- Current state (what exists today?)
- Desired outcome (what should exist?)
- Constraints (budget, timeline, dependencies?)
- Success criteria (how do we know it works?)

### 2. Codebase Analysis
- Search for related patterns and conventions
- Identify integration points
- Map dependencies and impact radius
- Note existing solutions to similar problems

### 3. Knowledge Gaps
Identify what you don't know:
- Technical unknowns
- Business rule ambiguities
- Edge cases that need clarification

### 4. Output
Provide a structured summary:
```
## Understanding
[What I learned about the topic]

## Open Questions
[Questions that need answers before proceeding]

## Suggested Approach
[High-level direction based on findings]
```

## Rules
- Ask before assuming
- Explore before planning
- Understand before implementing
- Surface ambiguity early
