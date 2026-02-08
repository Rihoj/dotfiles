---
applyTo: '.github/**'
description: 'GitHub Actions CI/CD best practices: workflows, security, caching, testing, deployments, action version management. See references/github-actions-patterns.md for examples.'
---

# GitHub Actions CI/CD Best Practices

Design efficient, secure GitHub Actions pipelines. **For detailed workflow examples**, see [github-actions-patterns.md](references/github-actions-patterns.md).

## Action Version Management

### Live Verification Before Changes (CRITICAL)
Before changing ANY action version:
1. **Live fetch** `https://github.com/<owner>/<repo>/tags` or `/releases`
2. Confirm target version exists
3. Only then update the workflow

### Decision Logic
- If version exists: keep or upgrade
- If version doesn't exist: use highest available major
- Can't fetch? Ask user, don't guess
- **Never** downgrade without verification

### Anti-Patterns
❌ Downgrading based on assumption
❌ Switching to `@main` to "fix" version issues
❌ Changing versions without checking releases

## Workflow Structure

### Core Elements
- **Triggers (`on`)**: `push`, `pull_request`, `workflow_dispatch`, `schedule`
- **Concurrency**: Prevent simultaneous runs, avoid race conditions
- **Permissions**: Explicit `GITHUB_TOKEN` permissions (least privilege)
- **Reusable workflows**: `workflow_call` for common patterns

### Jobs
- Represent distinct phases: build, test, deploy, security scan
- Use `needs` for dependencies
- Pass data via `outputs`
- Conditional execution with `if`

### Steps and Actions
- Pin to full SHA or major version (`@v4`, not `@latest`)
- Use official actions from `actions/` org when possible
- Descriptive names for debugging
- Audit marketplace actions before use

## Security Best Practices

### Secret Management (CRITICAL)
- Store in GitHub Secrets, never in code
- Use environment protection for sensitive deployments
- OIDC for cloud authentication (AWS, Azure, GCP)
- Minimize secret scope

### GITHUB_TOKEN Permissions
Start with read-only, add write only when needed:
```yaml
permissions:
  contents: read
  pull-requests: write
```

### Security Scanning
- **Dependency Review**: `dependency-review-action` on PRs
- **SAST**: CodeQL for code analysis
- **Container Scanning**: Trivy, Snyk for images
- **Secret Scanning**: Prevent credential leaks

### Image Signing
- Sign container images (Cosign, Docker Content Trust)
- Verify signatures before deployment
- Immutable infrastructure

## Optimization

### Caching
- Cache dependencies: `actions/cache@v3`
- Key by lock file hash
- Use `restore-keys` for fallback
- Scope: repository + branch

### Matrix Strategies
- Parallel execution across OS, versions, platforms
- `fail-fast: false` for complete coverage
- `exclude` for unsupported combinations

### Fast Builds
- Shallow checkout: `fetch-depth: 1`
- Self-hosted runners for specialized needs
- BuildKit for Docker parallelization
- Artifacts for inter-job data transfer

## Testing Strategies

### Test Pyramid
1. **Unit tests**: Fast, isolated, every push
2. **Integration tests**: Real dependencies, PR merge
3. **E2E tests**: Full user flows, pre-deployment
4. **Performance tests**: Load/stress, scheduled or manual

### Test Reporting
- Upload coverage to Codecov/Coveralls
- JUnit XML for GitHub checks
- Screenshots/videos on failure
- Status badges in README

## Deployment Strategies

### Environments
- **Staging**: Pre-production validation, auto-deploy from develop
- **Production**: Manual approval required, health checks mandatory

### Deployment Types
- **Rolling**: Gradual replacement (default)
- **Blue/Green**: Full environment swap
- **Canary**: Incremental rollout with monitoring
- **Feature Flags**: Deploy code, toggle features

### Rollback
- Keep previous versions deployable
- Automated rollback on health check failure
- Manual rollback workflow with `workflow_dispatch`
- Clear communication plan

## Workflow Checklist

✅ Explicit permissions (least privilege)
✅ Secrets in GitHub Secrets, not code
✅ Actions pinned to versions (not `@latest`)
✅ Caching for dependencies
✅ Security scanning (SAST, dependency, containers)
✅ Test coverage reporting
✅ Health checks post-deployment
✅ Rollback plan documented
✅ Environment protection for production
✅ OIDC for cloud authentication

## Common Anti-Patterns

❌ Using `@latest` for action versions
❌ Hardcoding secrets in workflows
❌ No caching (slow builds)
❌ Missing security scans
❌ No health checks
❌ Deploying without approval gates
❌ No rollback strategy
❌ Overly broad `GITHUB_TOKEN` permissions

**See [github-actions-patterns.md](references/github-actions-patterns.md)** for complete examples of:
- Multi-stage build/test/deploy workflows
- Security scanning integration
- Matrix testing strategies
- Reusable workflows
- Rollback procedures
