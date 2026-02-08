````prompt
---
description: Systematic code improvement through refactoring, identifying bottlenecks and technical debt
name: refactor
argument-hint: "Describe the code area or feature to refactor"
agent: software-engineer
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'awesome-copilot/*', 'agent', 'memory']
---

# Refactor Coordination Prompt

## Purpose

This prompt orchestrates systematic code improvement by delegating to software engineers, performance specialists, and tech leads, synthesizing code quality metrics, bottleneck analysis, and technical debt assessment.

## When to Use

- **Code smell detection** — Identify patterns indicating deeper design issues
- **Performance optimization** — Find and fix bottlenecks affecting latency/throughput
- **Technical debt reduction** — Prioritize and address accumulated tech debt
- **Architecture improvement** — Modernize code structure and patterns
- **Maintainability enhancement** — Increase code readability and testability
- **Dependency modernization** — Upgrade libraries and remove obsolete patterns

## Hard Rules

- **Always delegate** via `#runSubagent` — Never refactor without specialist input
- **Keep synthesis under 200 words** — Focus on impact and priorities
- **Use 5-section template** — No exceptions
- **Request focused refactor plans** from specialists to avoid length limits
- **Measure improvements** — Establish metrics before and after
- **Total response under 500 words** (excluding agent delegations)

## Instructions

1. **Analyze the codebase**: ${input:codearea}
2. **Identify refactoring opportunities**: Code smells, performance hotspots, design patterns, test coverage
3. **Delegate sequentially**:
   - Call `#software-engineer` for refactoring approach and code patterns
   - Call `#performance-engineer` for bottleneck analysis and optimization impact
   - Call `#tech-lead` for architectural considerations and priority ranking
   - Request code quality metrics and improvement strategy
4. **Synthesize results**: Integrate refactoring priorities, performance gains, and architecture improvements
5. **Document refactoring decisions**: Log technical choices and trade-offs
6. **Define refactoring roadmap**: Provide phased approach with measurable improvements

## Delegation Strategy

For the given code area, delegate to appropriate specialists:

| Task Type | Delegate To | Request |
|-----------|-------------|---------|
| Code refactoring, patterns | `#software-engineer` | "Refactor code smells in: ${input:codearea}" |
| Performance bottlenecks, optimization | `#performance-engineer` | "Analyze performance hotspots in: ${input:codearea}" |
| Architecture, technical debt prioritization | `#tech-lead` | "Assess technical debt in: ${input:codearea}" |
| Test coverage, maintainability | `#qa-test` | "Evaluate test coverage for: ${input:codearea}" |
| Security debt, vulnerability fixes | `#security` | "Review security issues in: ${input:codearea}" |
| Database query optimization | `#database-admin` | "Optimize queries in: ${input:codearea}" |

## Output Template (Strict Format)

Every response MUST follow this exact structure:

### 1. Brief Plan
[2-3 sentences summarizing refactoring approach, bottleneck priorities, and expected improvements]

### 2. Delegations
**Specialist Called**: `#agent-name`
**Request**: [What was asked]
**Rationale**: [Why this specialist]

[Repeat for each delegation]

### 3. Synthesis
[Under 200 words: prioritized refactoring list, performance gains, code quality improvements, architectural benefits, risk mitigation]

### 4. Decision Log
1. **Decision**: [What was decided about refactoring approach]
   - **Rationale**: [Why this strategy]
   - **Alternatives Rejected**: [What was not chosen and why]

2. **Decision**: [...]
   - **Rationale**: [...]
   - **Alternatives Rejected**: [...]

### 5. Next Actions
1. [Concrete refactoring action with responsible party]
2. [Concrete refactoring action with responsible party]
3. [Concrete refactoring action with responsible party]

## Example Usage

**User Input**: `/refactor User service with large monolithic handler and N+1 queries`

**Expected Output**:
```
### 1. Brief Plan
Decompose monolithic user service into focused handlers (authentication, profile, 
preferences). Fix N+1 queries with batch loading and eager fetching. Improve test 
coverage from 62% to 85%. Expected 30% latency reduction.

### 2. Delegations
**Specialist Called**: #performance-engineer
**Request**: "Profile user service for performance bottlenecks and N+1 queries"
**Rationale**: Need quantified impact of database queries and latency hotspots

**Specialist Called**: #software-engineer
**Request**: "Design refactored handler structure with separation of concerns"
**Rationale**: Need implementation pattern for handler decomposition

**Specialist Called**: #tech-lead
**Request**: "Prioritize technical debt in user service and assess architecture"
**Rationale**: Need strategic guidance on refactoring roadmap and dependencies

### 3. Synthesis
Performance engineer identifies N+1 queries in user profile endpoint (50ms per 
user × 100 batch), causing 5-second response times. Software engineer recommends 
splitting into 3 handlers: auth (JWT), profile (caching + batch loading), preferences 
(NoSQL queries). Tech-lead prioritizes database optimization first (biggest impact), 
then handler decomposition (maintainability). Measurable improvements: 1) Batch 
queries (5s → 500ms), 2) Cache profile data (reduces 60% queries), 3) Async 
preference loading (improves UX).

### 4. Decision Log
1. **Decision**: Fix N+1 queries before handler decomposition
   - **Rationale**: Highest impact (10x latency improvement), unblocks other work
   - **Alternatives Rejected**: Decompose first (misses quick wins, higher complexity)

2. **Decision**: Use batch loading with DataLoader pattern
   - **Rationale**: Industry standard, prevents future N+1 issues, cacheable
   - **Alternatives Rejected**: Eager fetching (less flexible), join queries (complex schema)

3. **Decision**: Decompose into 3 handlers with shared cache layer
   - **Rationale**: Clear responsibilities, reusable cache logic, testable
   - **Alternatives Rejected**: Monolithic with feature flags (less maintainable)

### 5. Next Actions
1. @performance-engineer: Profile and quantify N+1 impact with load testing
2. @software-engineer: Implement batch loading with DataLoader
3. @software-engineer: Add distributed caching for profile data
4. @qa-test: Increase test coverage to 85% during refactoring
5. @tech-lead: Plan handler decomposition and review separation of concerns
```

## Success Criteria

✅ Bottlenecks identified and quantified (baseline metrics)
✅ Refactoring priorities ranked by impact
✅ Code quality metrics established and tracked
✅ Technical debt assessment documented
✅ Performance improvements measured (before/after)
✅ Test coverage increases, maintainability improves

## Notes

- Always measure baseline metrics before refactoring
- Prioritize bottlenecks by actual impact, not perceived issues
- Use feature flags to ship refactored code safely
- Break large refactorings into small, reviewable PRs
- Maintain backward compatibility unless deprecation is explicit

````
