---
description: Review workspace changes and create conventional commits using intelligent splitting
name: commit
argument-hint: "Optional: specify files or leave empty to review all changes"
agent: change-splitter-committer
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'mcp_docker/git_add', 'mcp_docker/git_checkout', 'mcp_docker/git_commit', 'mcp_docker/git_create_branch', 'mcp_docker/git_diff', 'mcp_docker/git_diff_staged', 'mcp_docker/git_diff_unstaged', 'mcp_docker/git_init', 'mcp_docker/git_log', 'mcp_docker/git_reset', 'mcp_docker/git_show', 'mcp_docker/git_status', 'agent', 'memory', 'todo']
---

# Create Commits

## Purpose

This prompt reviews workspace changes, groups related modifications into logical commits, and generates conventional commit messages following the Conventional Commits specification with clear categorization and scope.

## When to Use

- **Feature development** with multiple related changes
- **Bug fixes** needing clear change tracking
- **Refactoring** requiring logical commit splitting
- **Multi-part improvements** affecting different systems
- **Review & commit workflow** where you want structured commits
- **Automated change organization** from larger development sessions

## Hard Rules

- **Always delegate to #code-reviewer first** — Assess all changes before splitting
- **Follow Conventional Commits spec** — `type(scope): description`
- **One logical change per commit** — No mega-commits
- **Keep messages under 72 characters** (first line) — Enforced
- **Use body text for details** — Explain WHY, not WHAT
- **Never force-push without consent** — Preserve collaboration
- **Validate conventional format** — type must be valid (feat, fix, refactor, docs, test, chore, style, perf, ci)
- **Total response under 500 words** (excluding delegations)

## Instructions

1. **Identify changes**: Review staged/unstaged files in workspace
2. **Delegate to specialists**:
   - Call `#code-reviewer` to assess changes: "Review these changes for: ${input:focus}"
   - Analyze impact, correctness, and logical grouping
3. **Delegate to committer**:
   - Call `#change-splitter-committer` to split and commit: "Create commits for: ${input:focus}"
   - Request specific commit grouping based on review
4. **Generate messages**: Ensure each follows Conventional Commits
5. **Validate output**: Verify commits are atomic and well-described
6. **Present options**: Let user review before committing

## Delegation Strategy

For any commit workflow, follow this sequence:

| Step | Delegate To | Request |
|------|-------------|---------|
| Change Assessment | `#code-reviewer` | "Review these workspace changes for: ${input:focus}" |
| Split & Organize | `#change-splitter-committer` | "Create commits for these changes with messages following Conventional Commits" |
| Validation | User | Review proposed commits before `git commit` |

## Conventional Commits Format

**Strict Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Valid Types**:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring without feature change
- `perf`: Performance improvement
- `docs`: Documentation changes only
- `style`: Formatting, missing semicolons, etc. (no code change)
- `test`: Test additions or modifications
- `chore`: Dependency updates, tooling, build system
- `ci`: CI/CD pipeline changes

**Subject Line** (50 chars max):
- Imperative mood ("add", "fix", "refactor")
- No period at end
- No capitalization

**Example**:
```
feat(auth): implement JWT token refresh mechanism

Add automatic token refresh before expiry with HTTP-only 
cookie storage. Implement 15-minute access token lifespan 
with 7-day refresh token rotation.

Fixes #123
```

## Output Template (Strict Format)

Every response MUST follow this exact 5-section structure:

### 1. Change Summary
```
Total Files Modified: [N]
Total Insertions: [+N]
Total Deletions: [-N]
Key Areas Affected: [List 3-5 main areas]
Assessment: [1-2 sentences on overall change quality]
```

### 2. Code Review Assessment
**Specialist Called**: `#code-reviewer`
**Request**: "Review workspace changes for: ${input:focus}"
**Findings**: [Key observations on correctness, impact, and logical grouping]

### 3. Proposed Commit Grouping
```
Commit 1: [type(scope): subject]
- Files: [list affected files]
- Rationale: [why grouped together]

Commit 2: [type(scope): subject]
- Files: [list affected files]
- Rationale: [why grouped together]

Commit N: [...]
```

### 4. Full Commit Messages
```
Commit 1:
<type>(<scope>): <subject>
<blank line>
<body explaining why/what>
<blank line>
<footer if applicable>

---

Commit 2:
[...]
```

### 5. Next Actions
1. Review proposed commits above
2. Adjust grouping or messages if needed
3. Run: `git add <files>` for each commit group
4. Run: `git commit -m '<message>'` for each
5. Verify: `git log --oneline -N` to see new commits

## Example Usage

**User Input**: `/commit`

**Expected Output**:
```
### 1. Change Summary
Total Files Modified: 5
Total Insertions: +145
Total Deletions: -32
Key Areas Affected: Authentication module, User service, API endpoints, Tests
Assessment: Well-structured changes implementing JWT authentication with proper security 
patterns and comprehensive test coverage.

### 2. Code Review Assessment
**Specialist Called**: #code-reviewer
**Request**: "Review workspace changes for authentication implementation"
**Findings**: Changes implement JWT auth correctly with HTTP-only cookies, proper error 
handling, and comprehensive tests. No security issues identified. Changes logically separate 
into authentication logic, service integration, and tests.

### 3. Proposed Commit Grouping
Commit 1: feat(auth): implement JWT token management
- Files: src/auth/jwt.ts, src/auth/tokens.ts, src/types/auth.ts
- Rationale: Core authentication logic grouped together

Commit 2: feat(api): add authentication middleware
- Files: src/middleware/auth.ts, src/api/auth.routes.ts
- Rationale: API integration layer separate from logic

Commit 3: test(auth): add JWT authentication tests
- Files: src/auth/__tests__/jwt.test.ts, src/api/__tests__/auth.test.ts
- Rationale: All authentication tests together

### 4. Full Commit Messages
Commit 1:
feat(auth): implement JWT token management

- Create JWT encoder/decoder with HS256 signature
- Implement refresh token rotation (15min access, 7day refresh)
- Add token validation and expiry checks
- Store tokens in HTTP-only cookies for security

Commit 2:
feat(api): add authentication middleware

- Add JWT verification middleware to protected routes
- Implement error handling for missing/invalid tokens
- Add user context injection to request object
- Validate token claims before processing requests

Commit 3:
test(auth): add JWT authentication tests

- Test token creation and validation
- Test token refresh and expiry
- Test middleware error handling
- Test XSS protection with HTTP-only cookies

### 5. Next Actions
1. Review proposed commits above
2. Run: git add src/auth/jwt.ts src/auth/tokens.ts src/types/auth.ts
3. Run: git commit -m 'feat(auth): implement JWT token management'
4. Run: git add src/middleware/auth.ts src/api/auth.routes.ts
5. Run: git commit -m 'feat(api): add authentication middleware'
```

## Success Criteria

✅ All changes reviewed by code-reviewer  
✅ Commits follow Conventional Commits format exactly  
✅ Logical grouping makes sense (one feature/fix per commit)  
✅ Commit messages explain WHY changes were made  
✅ No files missing or duplicated across commits  
✅ Each commit can stand alone (buildable, testable)  
✅ First line is imperative mood and under 50 chars  

## Notes

- Use `git diff` to preview changes before committing
- Commits are atomic: each should build and pass tests independently
- For very large changesets, consider multiple `/commit` sessions
- Conventional Commits enable automated changelog generation and semantic versioning
