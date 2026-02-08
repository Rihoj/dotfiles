````prompt
---
description: Coordinate deployments with health checks, SLO validation, and rollback planning
name: deploy
argument-hint: "Describe the service/feature and target environment (staging/prod)"
agent: devops-engineer
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'awesome-copilot/*', 'mcp_docker/*', 'agent', 'memory']
---

# Deploy Coordination Prompt

## Purpose

This prompt orchestrates coordinated deployments by delegating to DevOps, SRE, and release management specialists, synthesizing health checks, SLO validation, and rollback strategies.

## When to Use

- **Staging deployments** — Validate changes in production-like environment
- **Production releases** — Coordinate deployment with health monitoring and rollback planning
- **Multi-region deployments** — Manage canary rollouts, traffic shifting
- **Service mesh updates** — Coordinate infrastructure changes with health validation
- **Emergency rollbacks** — Structured incident response and service recovery

## Hard Rules

- **Always delegate** via `#runSubagent` — Never deploy without specialist input
- **Keep synthesis under 200 words** — Focus on risks and health criteria
- **Use 5-section template** — No exceptions
- **Request focused deployment plans** from specialists to avoid length limits
- **Define rollback criteria upfront** — Know exit strategy before deployment
- **Total response under 500 words** (excluding agent delegations)

## Instructions

1. **Analyze the deployment**: ${input:deployment}
2. **Identify deployment requirements**: Infrastructure changes, traffic patterns, health metrics, SLO impact
3. **Delegate sequentially**:
   - Call `#devops-engineer` for deployment strategy and infrastructure validation
   - Call `#release-manager` for release coordination and change management
   - Call `#sre` for SLO validation and rollback criteria
   - Request health check configurations
4. **Synthesize results**: Integrate deployment strategy, rollback triggers, and SLO safeguards
5. **Document deployment decisions**: Log critical choices and risk mitigations
6. **Define deployment execution plan**: Provide ordered steps with health checkpoints

## Delegation Strategy

For the given deployment, delegate to appropriate specialists:

| Task Type | Delegate To | Request |
|-----------|-------------|---------|
| Deployment strategy, infrastructure | `#devops-engineer` | "Plan deployment for: ${input:deployment}" |
| Release coordination, change management | `#release-manager` | "Coordinate release for: ${input:deployment}" |
| SLO validation, monitoring, rollback | `#sre` | "Validate SLOs and plan rollback for: ${input:deployment}" |
| Canary/blue-green strategy | `#devops-engineer` | "Design deployment strategy for: ${input:deployment}" |
| Database migrations | `#database-admin` | "Plan schema changes for: ${input:deployment}" |
| Network/security validation | `#security` | "Review deployment security for: ${input:deployment}" |

## Output Template (Strict Format)

Every response MUST follow this exact structure:

### 1. Brief Plan
[2-3 sentences summarizing deployment strategy, health validation approach, and rollback criteria]

### 2. Delegations
**Specialist Called**: `#agent-name`
**Request**: [What was asked]
**Rationale**: [Why this specialist]

[Repeat for each delegation]

### 3. Synthesis
[Under 200 words: deployment phases, health metrics, rollback triggers, SLO safeguards, team coordination points]

### 4. Decision Log
1. **Decision**: [What was decided about deployment approach]
   - **Rationale**: [Why this strategy]
   - **Alternatives Rejected**: [What was not chosen and why]

2. **Decision**: [...]
   - **Rationale**: [...]
   - **Alternatives Rejected**: [...]

### 5. Next Actions
1. [Concrete deployment action with responsible party]
2. [Concrete deployment action with responsible party]
3. [Concrete deployment action with responsible party]

## Example Usage

**User Input**: `/deploy API v2.1.0 to production with database schema changes`

**Expected Output**:
```
### 1. Brief Plan
Deploy API v2.1.0 using canary rollout (5% → 25% → 100%) with automated health 
checks every 2 minutes. Coordinate database migration with pre-deployment script. 
Monitor error rate and latency SLOs; auto-rollback if thresholds exceeded.

### 2. Delegations
**Specialist Called**: #devops-engineer
**Request**: "Design canary deployment strategy for API v2.1.0 with schema changes"
**Rationale**: Need deployment architecture and migration sequencing

**Specialist Called**: #sre
**Request**: "Define SLO thresholds and rollback triggers for API v2.1.0 deployment"
**Rationale**: Health validation and safe rollback criteria are SRE responsibility

**Specialist Called**: #release-manager
**Request**: "Coordinate v2.1.0 release timing and team communication"
**Rationale**: Need change management and stakeholder alignment

### 3. Synthesis
DevOps recommends canary rollout (5%, 25%, 100%) with 15-minute hold between stages. 
Database migration must run pre-deployment with rollback script prepared. SRE 
sets rollback triggers: error rate > 5%, latency p99 > 500ms, or Slack alert. 
Release manager needs 30-min team coordination window. Health checks: API response 
time, error rate, database connectivity every 2 minutes. Single point of failure: 
database migration reversibility must be tested.

### 4. Decision Log
1. **Decision**: Use canary rollout (5% → 25% → 100%)
   - **Rationale**: Reduces blast radius, catches issues early
   - **Alternatives Rejected**: Big bang (too risky), blue-green (more resource overhead)

2. **Decision**: Auto-rollback if error rate exceeds 5%
   - **Rationale**: Aligns with service SLO, prevents cascading failures
   - **Alternatives Rejected**: Manual rollback (too slow), looser thresholds (impacts users)

### 5. Next Actions
1. @devops-engineer: Prepare database migration scripts with rollback procedures
2. @devops-engineer: Configure canary traffic shaping (5% → 25% → 100%)
3. @sre: Set up monitoring alerts for error rate, latency, and rollback triggers
4. @release-manager: Schedule 30-min team sync 15 minutes before deployment
5. @devops-engineer: Execute deployment and monitor health checks every 2 minutes
```

## Success Criteria

✅ Deployment strategy aligns with risk tolerance
✅ Health metrics defined with clear rollback triggers
✅ SLOs validated and safeguards activated
✅ Rollback procedures tested and documented
✅ Team communication plan coordinated
✅ Deployment proceeds with confidence

## Notes

- Always test rollback procedures in staging before production
- Database migrations are highest risk; validate revertibility
- Use canary deployments for customer-facing services
- Define SLO thresholds before deployment, not during

````
