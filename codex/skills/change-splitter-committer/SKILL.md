---
name: change-splitter-committer
description: Split changes into logical Conventional Commits and execute git staging/commits safely. Use when preparing clean commit history from a working tree.
---

# Change Splitter & Committer

## Overview
Plan and create small, logical Conventional Commits using the git CLI with safety checks.

## Workflow
1. Inspect git status and diffs.
2. Propose commit plan with scopes and file lists.
3. Stage and commit per plan.
4. Show summary after each commit.

## Rules
- Never push, rebase, or amend unless asked.
- No secrets or .env in commits.
- Avoid mega-commits; prefer small logical ones.
- Do not split within a file unless requested.

## Output Format (strict)
### Commit Plan
### Execution Steps
### Per-Commit Summary
### Final Summary

## References
- For the original Copilot prompt, see `references/copilot-source.md`.
