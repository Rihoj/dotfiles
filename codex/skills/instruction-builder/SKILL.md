---
name: instruction-builder
description: Create custom instruction files and AGENTS.md configuration for GitHub Copilot. Use when defining `.instructions.md`, `.github/copilot-instructions.md`, or multi-agent setups.
---

# Instruction Builder

## Overview
Design Copilot instruction files with correct frontmatter, scopes, and examples.

## Workflow
1. Identify instruction type (conditional, workspace-wide, AGENTS).
2. Define scope and glob patterns.
3. Draft concise rules with examples and anti-patterns.
4. Validate frontmatter and pattern coverage.

## Rules
- Use imperative, actionable guidance.
- Keep scopes narrow and non-overlapping.
- Include good/bad examples when possible.

## Output Format (strict)
### Instruction Type
### Scope & ApplyTo
### Content Draft
### Validation Checklist
### Installation Steps

## References
- For the original Copilot prompt, see `references/copilot-source.md`.
