---
description: Perform structured code review with severity ratings and actionable feedback
name: review-code
argument-hint: "Optional: specify files or leave empty to review selection"
agent: code-reviewer
tools: ['vscode', 'execute', 'read', 'agent', 'edit', 'search', 'web', 'todo', 'memory']
---

# Review Code

## Purpose

This prompt performs a comprehensive code review focusing on correctness, security, reliability, performance, and maintainability with severity-based prioritization.

## When to Use

- **Pre-merge reviews** for pull requests
- **Security audits** for sensitive code
- **Performance reviews** for critical paths
- **Refactoring validation** before large changes
- **Learning reviews** to understand code quality

## Hard Rules

- **Never edit files** — Review only, suggest fixes
- **Keep total under 500 words** — Be specific, not verbose
- **Use 5-section format** — No exceptions
- **Assign severity correctly** — P0 (critical) to P3 (nice-to-have)
- **Point to exact lines** — Specific, not vague
- **Explain impact** — Why each issue matters
- **Suggest minimal patches** — Show the fix, don't rewrite everything

## Instructions

1. **Identify code to review**:
   - If `${selection}` exists: Review selected code
   - If `${input:files}` provided: Review specified files
   - Otherwise: Ask user to select code or specify files
2. **Analyze across dimensions**:
   - **Correctness**: Logic errors, null handling, edge cases
   - **Security**: Input validation, injection, secrets, auth
   - **Reliability**: Error handling, retries, timeouts, cleanup
   - **Performance**: N+1 queries, hot paths, algorithms
   - **Maintainability**: Clarity, duplication, tests
   - **Observability**: Logging, metrics, tracing
3. **Prioritize issues**: P0 (blocks merge) → P1 (fix before merge) → P2 (fix soon) → P3 (nice to have)
4. **Provide patches**: Specific code fixes for key issues
5. **Ask questions**: Clarify unclear design decisions

## Severity Definitions

**P0 (Critical)** — Blocks merge, breaks functionality or security:
- Security vulnerabilities (injection, auth bypass, secrets exposure)
- Data corruption or loss
- Production crashes or outages
- Resource leaks causing system failure

**P1 (High)** — Should fix before merge:
- Logic errors affecting core functionality
- Missing error handling in critical paths
- Performance issues in hot paths (O(n²), N+1 queries)
- Reliability concerns (no retries, no timeouts)

**P2 (Medium)** — Fix soon, non-blocking:
- Code clarity issues
- Missing tests for edge cases
- Minor performance inefficiencies
- Inconsistent patterns or naming

**P3 (Low)** — Nice to have:
- Naming improvements
- Code style inconsistencies
- Documentation typos
- Refactoring opportunities

## Output Template (Strict Format)

Every response MUST follow this 5-section structure:

### 1. Summary
[2-3 sentences: overall code quality, key findings, recommendation (✅ Approve / ⚠️ Needs Work / 🛑 Block)]

### 2. Major Issues (P0-P1) — Must Fix

**[Issue Title]** (P0 or P1) — `${file}:${line}`
- **Impact**: [What breaks, security risk, data loss, etc.]
- **Evidence**: [Code snippet or specific explanation]
- **Fix**: [Specific recommendation or reference patch in Section 5]

**[Issue Title]** (P0 or P1) — `${file}:${line}`
- **Impact**: [...]
- **Evidence**: [...]
- **Fix**: [...]

[Repeat for each P0/P1 issue]

### 3. Minor Issues (P2-P3) — Should Fix

**[Issue Title]** (P2 or P3) — `${file}:${line}`
- **Issue**: [What's suboptimal]
- **Recommendation**: [Suggested improvement]

**[Issue Title]** (P2 or P3) — `${file}:${line}`
- **Issue**: [...]
- **Recommendation**: [...]

[Repeat for each P2/P3 issue]

### 4. Questions & Clarifications

- ❓ [Question 1 about design decision or unclear intent]
- ❓ [Question 2 blocking approval until answered]
- ❓ [Question 3 about architectural choice]

### 5. Suggested Patches

```language
// File: path/to/file.ext:line
// Fix for [Issue Title from Section 2]

- // Old code (what to remove)
+ // New code (what to add)
  // Context line (unchanged)
```

```language
// File: path/to/another-file.ext:line
// Fix for [Another Issue Title]

- old_line()
+ new_fixed_line()
```

## Review Checklist

### Correctness
- [ ] Logic errors or off-by-one errors?
- [ ] Null/undefined pointer issues?
- [ ] Boundary conditions handled?
- [ ] Error handling complete?
- [ ] Resource cleanup in all paths?

### Security
- [ ] Input validation present?
- [ ] SQL injection possible?
- [ ] XSS vulnerabilities (if web)?
- [ ] Secrets hardcoded or logged?
- [ ] Authentication/authorization checked?

### Reliability
- [ ] Retries for transient failures?
- [ ] Timeouts configured?
- [ ] Circuit breakers (if external calls)?
- [ ] Graceful degradation?
- [ ] Idempotent operations?

### Performance
- [ ] N+1 queries?
- [ ] Inefficient algorithms in hot paths?
- [ ] Unnecessary allocations?
- [ ] Missing caching opportunities?
- [ ] Blocking operations inappropriately?

### Maintainability
- [ ] Code readable and clear?
- [ ] Unnecessary duplication?
- [ ] Tests adequate for changes?
- [ ] Documentation sufficient?
- [ ] Follows project conventions?

### Observability
- [ ] Useful logs (not excessive)?
- [ ] Error messages actionable?
- [ ] Metrics/tracing instrumented?
- [ ] Debug info available?

## Example Usage

**User Input**: `/review-code` (with code selected in editor)

**Expected Output**:
```
### 1. Summary
Code implements user login correctly but has a critical SQL injection vulnerability 
and missing rate limiting. 🛑 Blocking merge until P0 issue fixed. P1 issue should 
be addressed before production deployment.

### 2. Major Issues (P0-P1) — Must Fix

**SQL Injection in login query** (P0) — auth.js:45
- **Impact**: Attacker can bypass authentication using `' OR '1'='1`
- **Evidence**: Direct string concatenation: `SELECT * FROM users WHERE email='${email}'`
- **Fix**: Use parameterized queries (see patch in Section 5)

**No rate limiting on login endpoint** (P1) — auth.js:30
- **Impact**: Vulnerable to brute force attacks, no account lockout
- **Evidence**: No rate limiter middleware applied to /login route
- **Fix**: Add express-rate-limit middleware with 5 attempts per 15 minutes

### 3. Minor Issues (P2-P3) — Should Fix

**Error messages too verbose** (P2) — auth.js:50
- **Issue**: Error reveals "User not found in users table" - exposes database structure
- **Recommendation**: Return generic "Invalid credentials" for all auth failures

**Missing input validation** (P2) — auth.js:42
- **Issue**: Email format not validated before query
- **Recommendation**: Add email regex validation or use validator library

### 4. Questions & Clarifications

- ❓ Should we implement MFA in this PR or in a follow-up?
- ❓ Is there a session management strategy defined?
- ❓ What's the expected concurrent user load?

### 5. Suggested Patches

```javascript
// File: auth.js:45
// Fix for SQL Injection

- const query = `SELECT * FROM users WHERE email='${email}' AND password='${hashedPassword}'`;
- const user = await db.query(query);
+ const query = 'SELECT * FROM users WHERE email = ? AND password = ?';
+ const user = await db.query(query, [email, hashedPassword]);
```

```javascript
// File: auth.js:30
// Fix for Rate Limiting

+ const rateLimit = require('express-rate-limit');
+ const loginLimiter = rateLimit({
+   windowMs: 15 * 60 * 1000, // 15 minutes
+   max: 5, // 5 attempts
+   message: 'Too many login attempts, please try again later'
+ });
+ 
- app.post('/login', async (req, res) => {
+ app.post('/login', loginLimiter, async (req, res) => {
    // ... rest of handler
```
```

## When to Escalate

For complex issues, delegate to specialists:
- **Architecture concerns** → Call `#tech-lead` for design review
- **Security threats** → Call `#security` for threat modeling
- **Performance analysis** → Call `#sre` for capacity review
- **Test coverage** → Call `#qa-test` for test strategy

## Success Criteria

✅ Issues prioritized correctly (P0-P3)
✅ Feedback specific with file:line references
✅ Impact explained for each major issue
✅ Suggested patches are minimal and correct
✅ Questions identify genuine blockers
✅ Total length under 500 words
✅ No files edited (review only)

## Notes

- Use `${selection}` to review code highlighted in editor
- Use `${input:files}` to specify files explicitly
- Focus on high-impact issues, not nitpicks
- Provide actionable feedback, not lectures
- Consider calling specialists for deep-dive analysis
