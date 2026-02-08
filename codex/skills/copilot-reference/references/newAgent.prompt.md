---
description: Design and create custom GitHub Copilot agents with guided architecture and implementation
name: newAgent
argument-hint: "Describe the agent purpose and behavior"
agent: agent-builder
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'awesome-copilot/*', 'mcp_docker/*', 'agent', 'memory', 'todo']
---

# Design New Agent

## Purpose

This prompt guides you through designing and building custom GitHub Copilot agents that automate specialized workflows with clear responsibilities, decision logic, and output formats.

## When to Use

- **Specialized roles** needing dedicated agents (security reviewer, performance analyst, architect)
- **Repetitive workflows** that can be automated (code reviews, deployments, data analysis)
- **Team responsibilities** that benefit from consistent execution patterns
- **Custom expertise** integrating domain knowledge or proprietary systems
- **Handoff coordination** between different specialists in complex processes

## Hard Rules

- **Always use 5-section output template** — No exceptions
- **Single responsibility principle** — Each agent has one clear focus
- **Include decision framework** — How agent makes choices
- **Define integration points** — How agent collaborates with other agents
- **Specify success criteria** — How to measure agent effectiveness
- **Total response under 500 words** (excluding sub-delegations)
- **Request delegation to #agent-builder** — Don't design directly

## Instructions

1. **Define agent scope**: ${input:purpose}
2. **Identify responsibilities**:
   - Primary function (what does it do?)
   - Domain expertise (what does it know?)
   - Decision authority (what can it decide?)
   - Constraints (what can't it do?)
3. **Design delegation strategy**:
   - Analyze request type and route to appropriate sub-agents
   - Define collaboration patterns with other agents
   - Specify when to escalate or ask for human input
4. **Plan output format**:
   - Structure consistent with use cases
   - Include metadata for downstream integration
   - Add actionability and clarity
5. **Specify success metrics**:
   - How users will evaluate agent quality
   - Performance targets
   - Integration requirements

## Delegation Strategy

For designing new agents, delegate to the specialist:

| Agent Type | Delegate To | Request |
|-----------|------------|---------|
| Code analysis, review | `#agent-builder` | "Design agent to review code for: ${input:purpose}" |
| Infrastructure, DevOps | `#agent-builder` | "Design agent for infrastructure management: ${input:purpose}" |
| Security workflows | `#agent-builder` | "Design security agent for: ${input:purpose}" |
| Custom domain agent | `#agent-builder` | "Design agent that: ${input:purpose}" |

## Design Checklist

Before finalizing, ensure:

- [ ] Agent has single, clear responsibility
- [ ] Collaboration model defined (which agents it works with)
- [ ] Decision framework documented
- [ ] Input/output format specified
- [ ] Error handling strategy defined
- [ ] Success metrics established
- [ ] Integration tests planned

## Output Template (Strict Format)

Every agent design MUST include these 5 sections:

### 1. Agent Purpose & Scope
```
Name: [Agent name (kebab-case)]
Focus: [Single responsibility in 1-2 sentences]
Primary Use Cases: [3-5 scenarios when agent is used]
Decision Authority: [What can agent decide autonomously]
Constraints: [What agent cannot or should not do]
```

### 2. Responsibilities & Behavior
```
Core Tasks:
- [Task 1]: [How agent handles it]
- [Task 2]: [How agent handles it]

Decision Framework:
IF [condition] THEN [action]
IF [condition] THEN [action]

Success Indicators: [How users know agent worked well]
```

### 3. Integration & Collaboration
```
Collaborates With:
- [Agent]: [Purpose of collaboration]
- [Agent]: [Purpose of collaboration]

Escalation Points: [When to ask for human input]
Handoff Triggers: [When to delegate to other agents]
```

### 4. Input/Output Specification
```
Inputs:
- [Parameter]: [Description and format]
- [Parameter]: [Description and format]

Output Template:
[Structure agent will follow]

Metadata:
[Any tracking or integration data]
```

### 5. Success Criteria & Metrics
```
Agent is effective when:
✓ [Metric 1]
✓ [Metric 2]

Integration Requirements:
- [Requirement 1]
- [Requirement 2]

Performance Targets:
- [Target 1]
- [Target 2]
```

## Example Agent Design

**Input**: `/newAgent Design a database optimization agent`

**Output**:
```
### 1. Agent Purpose & Scope
Name: database-optimizer
Focus: Analyze database queries and recommend optimization strategies
Primary Use Cases: Query performance review, schema design audit, index recommendations, slow query detection
Decision Authority: Recommend indexes, suggest query rewrites, flag N+1 problems
Constraints: Cannot modify production databases, cannot suggest schema breaking changes, must validate changes

### 2. Responsibilities & Behavior
Core Tasks:
- Query Analysis: Identify expensive queries, plan complexity, missing indexes
- Schema Review: Check normalization, redundancy, data types
- Recommendations: Suggest specific indexes, rewrites, caching strategies

Decision Framework:
IF query runs >1s THEN prioritize optimization
IF O(n²) algorithm detected THEN flag as critical
IF N+1 pattern found THEN recommend batching/eager loading

Success Indicators: Clear recommendations provided, estimated performance improvement quantified

### 3. Integration & Collaboration
Collaborates With:
- #software-engineer: Implement query changes
- #devops-engineer: Apply schema changes in staging

Escalation Points: Breaking schema changes, major refactors
Handoff Triggers: When implementation needed beyond recommendations

### 4. Input/Output Specification
Inputs:
- queries: SQL queries to analyze
- schema: Database schema (DDL)
- metrics: Current performance metrics (optional)

Output Template:
## Query: [name]
**Issue**: [What's slow/wrong]
**Impact**: [Performance, scalability, cost]
**Recommendation**: [Specific fix]
**Estimated Improvement**: [Expected speedup]

### 5. Success Criteria & Metrics
Agent is effective when:
✓ Identifies real performance issues
✓ Recommendations are implementable
✓ Suggestions improve query speed by 50%+

Performance Targets:
- Analyze complex schema in <30 seconds
- Provide 3-5 actionable recommendations per query
```

## Success Criteria

✅ Agent has clear, single responsibility  
✅ Collaboration model is explicit  
✅ Decision framework covers key scenarios  
✅ Output format is consistent and actionable  
✅ Integration points with other agents defined  
✅ Success metrics are measurable  
✅ Constraints and limitations are clear  

## Next Steps

1. Clarify your agent's specific domain and use cases
2. Delegate to `#agent-builder` with the design template above
3. Review generated agent architecture
4. Implement agent.md file in your workspace
5. Test agent with sample scenarios
6. Gather feedback and iterate
