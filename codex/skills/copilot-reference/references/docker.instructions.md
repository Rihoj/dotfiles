---
applyTo: '**/Dockerfile,**/Dockerfile.*,**/*.dockerfile,**/docker-compose*.yml,**/docker-compose*.yaml,.dockerignore'
description: 'Core Docker best practices for optimized, secure containers. Multi-stage builds, security, minimal images. See references/docker-patterns.md for examples.'
---

# Docker Best Practices

Guide developers toward efficient, secure Docker images. **For detailed code examples**, see [docker-patterns.md](references/docker-patterns.md).

## Core Principles

1. **Immutability** - Images don't change; modifications create new images
2. **Portability** - Run consistently across all environments
3. **Isolation** - Proper resource and security boundaries
4. **Efficiency** - Minimal size, fast builds, reduced attack surface

## Dockerfile Essentials

### Multi-Stage Builds (Required)
- Separate build and runtime dependencies
- Use multiple `FROM` statements
- Copy only necessary artifacts: `COPY --from=build`
- Name stages descriptively: `AS build`, `AS production`
- **Benefit**: 10x smaller images, fewer vulnerabilities

### Base Image Selection
- Prefer `alpine` or `slim` variants
- Use official images from trusted sources
- Pin versions (avoid `latest` tag)
- Regular security updates

### Layer Optimization
- Order instructions by change frequency (least→most)
- Combine commands with `&&` to reduce layers
- Clean up in same RUN command
- Copy package files before source code for better caching

### .dockerignore
- Exclude: `.git`, `node_modules`, build artifacts, `.env`, tests
- Speeds builds, reduces context size
- Prevents accidental secret inclusion

### Security Defaults
- **Non-root user required**: `USER appuser`
- **Expose ports explicitly**: `EXPOSE 8080`
- **Health checks**: `HEALTHCHECK --interval=30s CMD ...`
- **Read-only filesystems** when possible

### Configuration
- Use `ENV` for defaults, not secrets
- `CMD` for default args, `ENTRYPOINT` for executable
- Externalize config via env vars or volumes
- Never hardcode credentials

## Security Best Practices

### Required Patterns
1. **Non-root user** - Create and switch before CMD
2. **Minimal base** - Alpine/distroless preferred
3. **No secrets in layers** - Use runtime secrets only
4. **Scan images** - Trivy, Hadolint, Snyk in CI
5. **Image signing** - Cosign or Docker Content Trust

### Security Scanning
- Dockerfile linting: Hadolint
- Vulnerability scanning: Trivy, Grype
- SBOM generation for compliance
- Block deployments on critical CVEs

### Capability Restrictions
- Drop all capabilities, add only needed ones
- Use `--security-opt=no-new-privileges`
- AppArmor/SELinux profiles for defense-in-depth

## Runtime Best Practices

### Resource Limits (Required)
Always set memory and CPU limits in docker-compose or Kubernetes manifests.

### Container Runtime
- Set memory and CPU limits always
- Use health checks for orchestration
- Implement graceful shutdown (SIGTERM handling)
- Log to stdout/stderr (12-factor)

### Orchestration Integration
- Liveness probes for restart decisions
- Readiness probes for traffic routing
- Startup probes for slow-starting apps
- Proper signal handling for graceful shutdown

## Development Workflow

### Build Optimization
- Leverage BuildKit for parallel builds
- Use `--target` for multi-stage efficiency
- Cache mounts for package managers
- `docker buildx` for multi-platform images

### CI/CD Integration
- Build once, deploy many times
- Tag with git SHA + semantic version
- Scan before push to registry
- Sign images in CI pipeline

### Debugging
- Use `--target` to stop at build stage
- Multi-stage allows test stage isolation
- Exec into running containers sparingly
- Prefer structured logging over exec

## Common Anti-Patterns (Avoid)

❌ `FROM ubuntu:latest` (use specific versions)
❌ `RUN apt-get update && apt-get install` (no cleanup)
❌ `COPY . .` (use .dockerignore)
❌ `ADD` (use `COPY` unless extracting archives)
❌ Running as root
❌ Hardcoding secrets
❌ Large images (>500MB signals inefficiency)
❌ No health checks
❌ Ignoring .dockerignore

## Quick Reference

**Optimal Dockerfile structure**:
1. FROM (minimal base)
2. RUN (install dependencies, cleanup in same layer)
3. COPY package files
4. RUN (install app dependencies)
5. COPY source code
6. USER (switch to non-root)
7. EXPOSE, HEALTHCHECK
8. CMD/ENTRYPOINT

**See [docker-patterns.md](references/docker-patterns.md)** for complete examples of:
- Multi-stage builds with testing
- Security scanning in CI
- Docker Compose configurations
- Health check implementations
- Capability restrictions
