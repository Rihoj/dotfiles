---
name: memory-agent
description: Manage structured project memory files (progress, decisions, context, todos, milestones, RCA index). Use when updating or querying `/memories/*.md` or maintaining RCA memory entries.
---

# Memory Agent

## Overview
Maintain structured memory files for progress, decisions, context, todos, milestones, and RCA indexes.

## Workflow
1. Identify the correct memory file.
2. Apply or query updates using the defined format.
3. Keep entries timestamped and attributed.
4. Escalate when memory changes affect direction.

## Rules
- Maintain consistent markdown templates.
- One logical update per operation.
- Prefer queries before adding duplicates.

## Memory Files
- `/memories/progress.md`
- `/memories/decisions.md`
- `/memories/context.md`
- `/memories/todos.md`
- `/memories/milestones.md`

## Output Format (strict)
### Confirmation
### Location
### Context Check

## References
- For the original Copilot prompt, see `references/copilot-source.md`.
