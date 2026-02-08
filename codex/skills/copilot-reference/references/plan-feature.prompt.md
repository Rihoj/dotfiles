---
description: Create comprehensive feature plan with requirements, design, and implementation roadmap
name: plan-feature
argument-hint: "Feature name or description"
agent: tech-lead
tools: ['vscode', 'execute', 'read', 'mcp_docker/fetch', 'agent', 'edit', 'search', 'web', 'todo', 'memory']
---

# Plan Feature

## Purpose

This prompt generates a complete feature plan including requirements analysis, architectural design, and sequenced implementation steps with clear acceptance criteria.

## When to Use

- **New features** requiring architecture and planning
- **Refactoring efforts** needing scope and sequencing
- **Technical spikes** to explore implementation approaches
- **Feature requests** that need breakdown before implementation

## Hard Rules

- **Plan, don't implement** — Design approach, don't write code
- **Keep total under 600 words** — Be concise and actionable
- **Use 3-part structure** — Requirements → Design → Implementation
- **Define clear boundaries** — What's in/out of scope
- **Think about testability** — Every step must be testable
- **Flag risks early** — Technical debt, breaking changes, complexity

## Instructions

1. **Analyze the feature**: ${input:feature}
2. **If code selected**: Consider ${selection} as context for refactoring/extension
3. **Define requirements**:
   - Functional requirements (what it does)
   - Non-functional requirements (performance, security, scalability)
   - Acceptance criteria (how to verify success)
   - Dependencies (what must exist first)
4. **Propose design**:
   - Architectural patterns that fit
   - Module boundaries and interfaces
   - Integration points
   - Data flow (if applicable)
5. **Create implementation plan**:
   - Sequenced steps (dependency-aware)
   - Acceptance criteria per step
   - Testability considerations
   - Risk mitigation strategies
6. **Define handoff**: Provide context for implementers

## Output Template (Strict Format)

Every response MUST follow this structure:

### 1. Requirements Analysis

**Objective**: [One sentence: what this feature achieves]

**Functional Requirements**:
- [Requirement 1: what the system must do]
- [Requirement 2: ...]
- [Requirement 3: ...]

**Non-Functional Requirements**:
- **Performance**: [Target latency, throughput]
- **Security**: [Auth, data protection needs]
- **Scalability**: [Expected load, growth]

**Acceptance Criteria**:
- [ ] [Criterion 1: measurable outcome]
- [ ] [Criterion 2: measurable outcome]
- [ ] [Criterion 3: measurable outcome]

**Dependencies**:
- [External dependency 1]
- [External dependency 2]

### 2. Design Proposal

**Approach**: [2-3 sentences on overall strategy]

**Architectural Patterns**:
- [Pattern 1 and why it fits]
- [Pattern 2 and why it fits]

**Module Boundaries**:
- **Module A**: [Responsibility]
- **Module B**: [Responsibility]
- **Integration**: [How they connect]

**Data Flow** (if applicable):
```
User → API → Service → Database
     ← JSON ← Transform ← Query
```

**Key Design Decisions**:
1. **Decision**: [What was chosen]
   - **Rationale**: [Why this choice]
   - **Trade-offs**: [What was sacrificed]

### 3. Implementation Plan

**Step 1**: [First implementation step]
- **Acceptance Criteria**: [How to verify]
- **Estimated Effort**: [Complexity indicator]
- **Risks**: [What could go wrong]

**Step 2**: [Second implementation step]
- **Acceptance Criteria**: [...]
- **Estimated Effort**: [...]
- **Risks**: [...]

**Step 3**: [Third implementation step]
- **Acceptance Criteria**: [...]
- **Estimated Effort**: [...]
- **Risks**: [...]

[Continue as needed, max 5-7 steps]

### 4. Boundaries & Scope

**In Scope**:
- [What this work includes]
- [Feature aspect 1]
- [Feature aspect 2]

**Out of Scope** (defer to later):
- [What this work explicitly excludes]
- [Future enhancement 1]
- [Future enhancement 2]

### 5. Risks & Mitigation

**Technical Risks**:
- **Risk**: [Potential issue]
  - **Mitigation**: [How to reduce risk]
  - **Contingency**: [Fallback plan]

**Integration Risks**:
- **Risk**: [...]
  - **Mitigation**: [...]

### 6. Handoff to Engineer

**Key Files**: [List relevant files from workspace]

**Critical Context**: [What implementer must know]

**Success Criteria**: [How to verify completion]

**Open Questions**: 
- [Question 1 that needs resolution]
- [Question 2 that needs resolution]

## Example Usage

**User Input**: `/plan-feature Add real-time notifications using WebSockets`

**Expected Output Structure**:
```
### 1. Requirements Analysis
**Objective**: Enable real-time push notifications to users via WebSocket connections

**Functional Requirements**:
- Establish WebSocket connections on user login
- Broadcast notifications to connected users
- Handle connection drops and reconnection
- Support notification types: alerts, messages, system events

**Non-Functional Requirements**:
- **Performance**: Support 10k concurrent connections, <100ms latency
- **Security**: Authenticate WebSocket connections, encrypt traffic
- **Scalability**: Horizontal scaling via Redis pub/sub

**Acceptance Criteria**:
- [ ] Users receive notifications within 100ms of event
- [ ] Connections automatically reconnect after network issues
- [ ] No duplicate notifications delivered
- [ ] Admin can broadcast to all connected users

**Dependencies**:
- Redis instance for pub/sub
- User authentication system
- Frontend WebSocket client

[Continue with Design Proposal, Implementation Plan, etc.]
```

## Decision Framework

When creating plans, consider:

- **Modularity**: Can this be broken into smaller deliverables?
- **Testability**: How will each step be tested?
- **Reversibility**: Can changes be rolled back if needed?
- **Performance**: Are there obvious performance concerns?
- **Security**: Any auth, validation, or secrets handling?
- **Observability**: How will we monitor/debug this?

## Success Criteria

✅ Requirements clearly defined with acceptance criteria
✅ Design proposes appropriate patterns and boundaries
✅ Implementation steps sequenced logically
✅ Risks identified with mitigation strategies
✅ Scope boundaries prevent feature creep
✅ Handoff provides all context needed
✅ Total length under 600 words

## Notes

- For large features, create multiple smaller plans
- Reference existing patterns in codebase where applicable
- Consider calling `#security` for security-critical features
- Consider calling `#sre` for reliability-critical features
- Use `${selection}` when planning refactoring of specific code
