---
description: Orchestrate complex tasks by delegating to specialist agents and synthesizing results with concise decision logs
name: orchestrate
argument-hint: "Describe the task or feature to coordinate"
agent: orchestrator
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'awesome-copilot/*', 'mcp_docker/*', 'agent', 'memory', 'todo']
---

# Orchestrate Task

## Purpose

This prompt coordinates complex multi-agent workflows by delegating to specialists, synthesizing their results, and producing a concise action plan with decision rationale.

## When to Use

- **Complex features** requiring multiple specialists (planning, implementation, testing, review)
- **Cross-cutting changes** affecting multiple systems or teams
- **Architecture decisions** needing input from tech-lead, security, SRE
- **Production issues** requiring coordinated response

## Hard Rules

- **Always delegate** via `#runSubagent` — Never implement directly
- **Keep synthesis under 200 words** — Focus on integration, not repetition
- **Use 5-section template** — No exceptions
- **Request small changes** from specialists to avoid length limits
- **Handle missing agents gracefully** — Suggest alternatives if agent doesn't exist
- **Total response under 500 words** (excluding agent delegations)

## Instructions

1. **Analyze the request**: ${input:task}
2. **Identify subtasks**: Break down into specialist areas (planning, implementation, testing, security, ops)
3. **Delegate sequentially**:
   - Call `#tech-lead` for implementation planning
   - Call `#software-engineer` for code implementation
   - Call `#qa-test` for test strategy
   - Call `#security` for security review
   - Call `#devops-engineer` or `#sre` for operational concerns
4. **Synthesize results**: Integrate findings into coherent recommendations
5. **Document decisions**: Log key choices with rationale
6. **Define next actions**: Provide 3-5 concrete steps

## Delegation Strategy

For the given task, delegate to appropriate specialists:

| Task Type | Delegate To | Request |
|-----------|-------------|---------|
| Architecture, planning | `#tech-lead` | "Create implementation plan for: ${input:task}" |
| Code implementation | `#software-engineer` | "Implement: ${input:task}" |
| Test strategy | `#qa-test` | "Design tests for: ${input:task}" |
| Code review | `#code-reviewer` | "Review changes for: ${input:task}" |
| CI/CD, infrastructure | `#devops-engineer` | "Setup deployment for: ${input:task}" |
| SLOs, monitoring | `#sre` | "Add observability for: ${input:task}" |
| Security review | `#security` | "Review security of: ${input:task}" |
| Database optimization | `#database-admin` | "Optimize queries for: ${input:task}" |
| Create custom agent | `#agent-builder` | "Design agent for: ${input:task}" |
| Create Agent Skill | `#skill-builder` | "Create skill for: ${input:task}" |
| Create instructions | `#instruction-builder` | "Create instructions for: ${input:task}" |
| Create Copilot hooks | `#hook-builder` | "Create hooks for: ${input:task}" |

## Output Template (Strict Format)

Every response MUST follow this exact structure:

### 1. Brief Plan
[2-3 sentences summarizing approach and strategy]

### 2. Delegations
**Specialist Called**: `#agent-name`
**Request**: [What was asked]
**Rationale**: [Why this specialist]

[Repeat for each delegation]

### 3. Synthesis
[Under 200 words: integrate results, resolve conflicts, unified recommendations]

### 4. Decision Log
1. **Decision**: [What was decided]
   - **Rationale**: [Why this choice]
   - **Alternatives Rejected**: [What was not chosen and why]

2. **Decision**: [...]
   - **Rationale**: [...]
   - **Alternatives Rejected**: [...]

### 5. Next Actions
1. [Concrete action with responsible party]
2. [Concrete action with responsible party]
3. [Concrete action with responsible party]

## Example Usage

**User Input**: `/orchestrate Add user authentication with JWT tokens`

**Expected Output**:
```
### 1. Brief Plan
Implement JWT-based authentication with secure token management, session handling, 
and comprehensive testing. Coordinate between tech-lead for architecture, 
software-engineer for implementation, and security for review.

### 2. Delegations
**Specialist Called**: #tech-lead
**Request**: "Design authentication architecture using JWT tokens"
**Rationale**: Need implementation plan and security boundaries

**Specialist Called**: #security
**Request**: "Review JWT implementation for security risks"
**Rationale**: Authentication is security-critical

### 3. Synthesis
Tech-lead recommends JWT with refresh tokens, HTTP-only cookies, and 15-minute 
expiry. Security validates approach but flags need for rate limiting and token 
rotation. Combined recommendation: Implement JWT auth with refresh mechanism, 
store tokens in HTTP-only cookies, add rate limiting middleware, implement 
token blacklist for logout, and comprehensive audit logging.

### 4. Decision Log
1. **Decision**: Use JWT with refresh tokens
   - **Rationale**: Stateless auth, scalable, industry standard
   - **Alternatives Rejected**: Session-based (doesn't scale), OAuth (overkill)

2. **Decision**: Store in HTTP-only cookies
   - **Rationale**: Prevents XSS attacks on token storage
   - **Alternatives Rejected**: localStorage (vulnerable to XSS)

### 5. Next Actions
1. @software-engineer: Implement JWT auth middleware with refresh logic
2. @software-engineer: Add rate limiting to prevent brute force
3. @qa-test: Create test suite for auth flows (login, refresh, logout)
4. @devops-engineer: Add auth environment variables to deployment config
5. @sre: Add monitoring for failed auth attempts
```

## Success Criteria

✅ Tasks correctly routed to appropriate specialists
✅ Results synthesized coherently (under 200 words)
✅ Decision rationale documented clearly
✅ Next actions are concrete and actionable
✅ No length-limit errors
✅ User knows exactly what to do next

## Notes

- For large tasks, break into smaller orchestration requests
- If an agent doesn't exist, suggest the capability needed
- Always set word/length limits when delegating to specialists
- Prioritize actions by impact and dependencies
