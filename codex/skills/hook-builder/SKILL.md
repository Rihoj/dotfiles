---
name: hook-builder
description: Design Copilot lifecycle hooks (.github/hooks/*.json) for validation, security checks, and audit logging. Use when defining sessionStart, preToolUse, or postToolUse hooks.
---

# Hook Builder

## Overview
Create safe, minimal Copilot hook configurations with clear lifecycle placement and security considerations.

## Workflow
1. Identify hook goal and lifecycle point.
2. Define command, timeout, and failure behavior.
3. Draft JSON config and validate safety.
4. Provide installation steps and dependencies.

## Rules
- Avoid hardcoded secrets.
- Prefer short timeouts and safe failures.
- Validate input to prevent command injection.

## Output Format (strict)
### Hook Proposal
### Generated Configuration
### Security Checklist
### Installation Steps
### Next Actions

## References
- For the original Copilot prompt, see `references/copilot-source.md`.
