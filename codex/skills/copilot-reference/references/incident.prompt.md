````prompt
---
description: Structured incident response with root cause analysis, mitigation coordination, and prevention planning
name: incident
argument-hint: "Describe the incident type and severity (outage/degradation/security)"
agent: incident-commander
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'awesome-copilot/*', 'agent', 'memory', 'web']
---

# Incident Coordination Prompt

## Purpose

This prompt orchestrates structured incident response by delegating to incident commander, SRE, DevOps, and security specialists, synthesizing root cause analysis, mitigation strategies, and prevention plans.

## When to Use

- **Production outages** — Service unavailable or degraded
- **Performance incidents** — Unexpected latency spikes or throughput reduction
- **Security events** — Data exposure, unauthorized access, anomalous behavior
- **Data loss incidents** — Corrupted, missing, or leaked customer data
- **Dependency failures** — Third-party service outages affecting your services
- **Cascading failures** — Multiple systems failing due to shared dependency

## Hard Rules

- **Always delegate** via `#runSubagent` — Never handle critical incidents solo
- **Keep synthesis under 200 words** — Focus on mitigation and root cause
- **Use 5-section template** — No exceptions
- **Request focused incident plans** from specialists to avoid length limits
- **Establish incident timeline** — Document discovery to resolution
- **Total response under 500 words** (excluding agent delegations)

## Instructions

1. **Understand the incident**: ${input:incident}
2. **Assess severity and scope**: Customer impact, affected services, duration, data exposure
3. **Delegate sequentially**:
   - Call `#incident-commander` for incident coordination and communication plan
   - Call `#sre` for root cause analysis and service recovery
   - Call `#devops-engineer` for infrastructure investigation and remediation
   - Call `#security` for impact assessment and forensics (if security-related)
   - Request mitigation strategy and prevention measures
4. **Synthesize results**: Integrate RCA findings, immediate mitigations, and long-term fixes
5. **Document incident response**: Log timeline, decisions, and learnings
6. **Define follow-up actions**: Provide post-incident review items and preventions

## Delegation Strategy

For the given incident, delegate to appropriate specialists:

| Task Type | Delegate To | Request |
|-----------|-------------|---------|
| Incident coordination, communication | `#incident-commander` | "Coordinate response to: ${input:incident}" |
| Root cause analysis, monitoring | `#sre` | "Investigate root cause of: ${input:incident}" |
| Infrastructure remediation, recovery | `#devops-engineer` | "Recover from: ${input:incident}" |
| Security forensics, breach assessment | `#security` | "Assess security impact of: ${input:incident}" |
| Database recovery, data integrity | `#database-admin` | "Restore data after: ${input:incident}" |
| Post-incident monitoring, alerting | `#sre` | "Improve detection for: ${input:incident}" |

## Output Template (Strict Format)

Every response MUST follow this exact structure:

### 1. Brief Plan
[2-3 sentences summarizing incident scope, immediate mitigation, and RCA approach]

### 2. Delegations
**Specialist Called**: `#agent-name`
**Request**: [What was asked]
**Rationale**: [Why this specialist]

[Repeat for each delegation]

### 3. Synthesis
[Under 200 words: incident impact, root cause findings, immediate mitigations, long-term preventions, timeline to recovery]

### 4. Decision Log
1. **Decision**: [What was decided for mitigation]
   - **Rationale**: [Why this approach]
   - **Alternatives Rejected**: [What was not chosen and why]

2. **Decision**: [...]
   - **Rationale**: [...]
   - **Alternatives Rejected**: [...]

### 5. Next Actions
1. [Concrete incident action with responsible party and timeline]
2. [Concrete incident action with responsible party and timeline]
3. [Concrete incident action with responsible party and timeline]

## Example Usage

**User Input**: `/incident Payment service returning 500 errors for 15 minutes, affecting 10% of transactions`

**Expected Output**:
```
### 1. Brief Plan
Payment service degradation affecting 10% of traffic for 15 minutes due to database 
connection pool exhaustion. Immediate mitigation: increase pool size and shed excess 
load. RCA focus: identify connection leak and implement circuit breaker. Long-term: 
add connection monitoring and auto-scaling.

### 2. Delegations
**Specialist Called**: #incident-commander
**Request**: "Coordinate payment service incident response and customer communication"
**Rationale**: Need incident tracking, team coordination, and customer notification

**Specialist Called**: #sre
**Request**: "Investigate root cause of database connection exhaustion in payment service"
**Rationale**: Need deep RCA and connection pool analysis

**Specialist Called**: #devops-engineer
**Request**: "Mitigate payment service by scaling database and circuit breaker"
**Rationale**: Need infrastructure changes and traffic management

**Specialist Called**: #security
**Request**: "Assess security impact of payment service error responses"
**Rationale**: Need to validate no customer data leaked in error messages

### 3. Synthesis
SRE identifies connection pool exhaustion in payment service: 300 queries/sec spike 
exhausted 100-connection pool in 2 minutes, causing 500 errors. DevOps immediately 
increases pool to 250 connections (mitigates current load). Root cause: missing 
connection close in retry logic, causing leak under high load. Payment service 
recovered after 8 minutes with increased pool. Customer impact: ~1,500 failed 
transactions (0.5% recovery possible). Long-term fixes: 1) Fix connection leak 
in retry code, 2) Add connection monitoring alerting, 3) Implement circuit breaker 
for database, 4) Add load shedding for non-critical features.

### 4. Decision Log
1. **Decision**: Immediately increase connection pool to 250
   - **Rationale**: Fast mitigation, recovers service while RCA continues
   - **Alternatives Rejected**: Rolling restart (longer recovery), code fixes (slow deployment)

2. **Decision**: Implement circuit breaker for database failures
   - **Rationale**: Prevents cascading failures, gracefully degrades service
   - **Alternatives Rejected**: Retry loops (amplifies load), bulkhead isolation (complex)

3. **Decision**: Offer transaction retry window for affected customers
   - **Rationale**: Recovers revenue, restores customer trust
   - **Alternatives Rejected**: Full refunds (unsustainable), ignore (reputational damage)

### 5. Next Actions
1. @devops-engineer: Increase payment DB connection pool to 250 (immediate)
2. @sre: Identify and patch connection leak in retry logic (next 2 hours)
3. @devops-engineer: Deploy circuit breaker for database failures (next 4 hours)
4. @sre: Add connection pool monitoring and alerting alerts (today)
5. @incident-commander: Schedule post-incident review for tomorrow (RCA, prevention)
```

## Success Criteria

✅ Immediate mitigation stops ongoing impact
✅ Root cause identified and understood
✅ Customer communication transparent and timely
✅ Service recovery timeline documented
✅ Long-term prevention measures defined
✅ Post-incident review scheduled

## Notes

- Prioritize mitigation speed over perfect understanding
- Establish timeline of events as early as possible
- Keep stakeholders updated every 15 minutes during active incident
- Post-incident review should include blameless culture focus
- Use incidents as learning opportunities for monitoring improvements
- Automate common mitigations (scaling, circuit breakers, failover)

````
