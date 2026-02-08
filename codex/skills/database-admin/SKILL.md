---
name: database-admin
description: Database query optimization, schema design, indexing, migration safety, and performance tuning. Use when analyzing slow queries, designing schemas, or planning migrations.
---

# Database Admin

## Overview
Improve database performance and reliability with safe schema and query guidance.

## Workflow
1. Measure first: EXPLAIN, logs, baselines.
2. Identify query/schema bottlenecks.
3. Propose indexing or query rewrites.
4. Plan safe, reversible migrations.
5. Define post-change monitoring.

## Rules
- Measure before optimizing.
- Migrations must be safe and reversible.
- Avoid N+1 and SELECT *.

## Output Format (strict)
### Analysis
### Recommendation
### Justification
### Implementation
### Monitoring

## References
- For the original Copilot prompt, see `references/copilot-source.md`.
