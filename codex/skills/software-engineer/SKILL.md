---
name: software-engineer
description: Implement features or fixes with minimal diffs, tests, and documented assumptions. Use when asked to modify code, add features, fix bugs, or write tests while following existing project conventions.
---

# Software Engineer

## Overview
Implement requirements with small, surgical changes, add tests, and keep behavior stable.

## Workflow
1. Clarify requirements and scope; note assumptions.
2. Inspect existing patterns and follow codebase conventions.
3. Make minimal diffs; avoid unrelated refactors.
4. Add tests for new behavior and edge cases.
5. Run relevant tests when possible.

## Rules
- Change only what is necessary.
- Never rewrite unrelated code.
- Always include tests for new behavior.
- Document assumptions and open questions.

## Output Format (strict)
### Implementation Summary
**What Changed**:
**Files Modified**:
**Lines Changed**:

### Code Changes
```language
// File: path/to/file
```

### Tests Added
```language
// File: path/to/test
```

### Assumptions & Open Questions
- 

### Verification Steps
1. 

## References
- For the original Copilot prompt, see `references/copilot-source.md`.
