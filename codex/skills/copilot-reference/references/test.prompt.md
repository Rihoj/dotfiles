````prompt
---
description: Coordinate automated testing, coverage analysis, and performance validation across the codebase
name: test
argument-hint: "Describe the code changes or features to test"
agent: qa-test
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'awesome-copilot/*', 'agent', 'memory']
---

# Test Coordination Prompt

## Purpose

This prompt orchestrates comprehensive testing workflows by delegating to test specialists and performance engineers, synthesizing coverage analysis, regression detection, and performance validation results.

## When to Use

- **Post-change testing** — Verify all affected code paths after modifications
- **Regression detection** — Identify unintended side effects in existing features
- **Coverage gap analysis** — Find untested code that needs attention
- **Performance validation** — Detect performance regressions in critical paths
- **Release readiness** — Comprehensive test suite before deployment

## Hard Rules

- **Always delegate** via `#runSubagent` — Never skip test planning
- **Keep synthesis under 200 words** — Focus on gaps, not test results
- **Use 5-section template** — No exceptions
- **Request focused test plans** from specialists to avoid length limits
- **Prioritize critical path tests** — Identify risks early
- **Total response under 500 words** (excluding agent delegations)

## Instructions

1. **Analyze the changes**: ${input:changes}
2. **Identify testing needs**: Unit tests, integration tests, performance benchmarks, regression test updates
3. **Delegate sequentially**:
   - Call `#qa-test` for comprehensive test strategy and coverage analysis
   - Call `#performance-engineer` for performance regression validation
   - Request test automation recommendations
4. **Synthesize results**: Integrate coverage gaps, performance baselines, and risk areas
5. **Document test decisions**: Log critical testing choices and risk mitigation
6. **Define test execution plan**: Provide ordered test execution with success criteria

## Delegation Strategy

For the given changes, delegate to appropriate specialists:

| Task Type | Delegate To | Request |
|-----------|-------------|---------|
| Test strategy, unit/integration tests | `#qa-test` | "Create comprehensive test plan for: ${input:changes}" |
| Performance baseline, regression detection | `#performance-engineer` | "Validate performance for: ${input:changes}" |
| Test automation, CI/CD test setup | `#devops-engineer` | "Setup test automation for: ${input:changes}" |
| Code coverage analysis | `#qa-test` | "Analyze coverage gaps in: ${input:changes}" |
| Load/stress testing | `#performance-engineer` | "Design load tests for: ${input:changes}" |

## Output Template (Strict Format)

Every response MUST follow this exact structure:

### 1. Brief Plan
[2-3 sentences summarizing test strategy, coverage focus, and performance validation approach]

### 2. Delegations
**Specialist Called**: `#agent-name`
**Request**: [What was asked]
**Rationale**: [Why this specialist]

[Repeat for each delegation]

### 3. Synthesis
[Under 200 words: identify coverage gaps, performance baselines, critical test areas, risk mitigation priorities]

### 4. Decision Log
1. **Decision**: [What was decided about test approach]
   - **Rationale**: [Why this strategy]
   - **Alternatives Rejected**: [What was not chosen and why]

2. **Decision**: [...]
   - **Rationale**: [...]
   - **Alternatives Rejected**: [...]

### 5. Next Actions
1. [Concrete test action with responsible party]
2. [Concrete test action with responsible party]
3. [Concrete test action with responsible party]

## Example Usage

**User Input**: `/test Changes to payment processing module including retry logic`

**Expected Output**:
```
### 1. Brief Plan
Create test suite covering payment retry scenarios, error handling, and idempotency. 
Validate performance impact on transaction latency. Ensure backward compatibility 
with existing payment flows.

### 2. Delegations
**Specialist Called**: #qa-test
**Request**: "Design test suite for payment retry logic with idempotency validation"
**Rationale**: Need comprehensive coverage of retry scenarios and edge cases

**Specialist Called**: #performance-engineer
**Request**: "Measure performance impact of retry logic on transaction processing"
**Rationale**: Retry mechanism could increase latency; baseline needed

### 3. Synthesis
QA recommends unit tests for retry logic (3 attempts, exponential backoff), 
integration tests for payment gateway interactions, and idempotency validation. 
Performance engineer identifies potential 5-10% latency increase with retries. 
Combined approach: Mock payment failures in tests, validate exponential backoff, 
add performance assertions (< 200ms per attempt), and implement metrics for 
retry success rate.

### 4. Decision Log
1. **Decision**: Use mock payment gateway for retry testing
   - **Rationale**: Safe, fast, deterministic failure scenarios
   - **Alternatives Rejected**: Real gateway testing (risky, slow, costly)

2. **Decision**: Set performance threshold at < 200ms per retry attempt
   - **Rationale**: Aligns with SLA requirements
   - **Alternatives Rejected**: Looser thresholds (would degrade user experience)

### 5. Next Actions
1. @qa-test: Create unit tests for retry logic and idempotency
2. @qa-test: Create integration tests with mock payment failures
3. @performance-engineer: Run performance baseline and document results
4. @devops-engineer: Add performance assertions to CI pipeline
5. @qa-test: Create regression tests for backward compatibility
```

## Success Criteria

✅ Test coverage gaps identified and prioritized
✅ Performance baselines established before deployment
✅ Critical paths protected with regression tests
✅ Test decisions documented with risk rationale
✅ Clear test execution order and success criteria
✅ Performance regressions detected early

## Notes

- For large changes, break into test layers (unit → integration → e2e)
- Always establish performance baselines before optimization attempts
- Prioritize regression tests for critical business features
- Use performance-engineer for customer-facing latency concerns

````
