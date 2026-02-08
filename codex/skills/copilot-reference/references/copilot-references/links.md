# Copilot Agent Suite — Curated References

This document provides authoritative links and resources for building, using, and extending the VS Code Custom Agent suite.

---

## Official VS Code Documentation

### Custom Agents
- [VS Code Custom Agents Overview](https://code.visualstudio.com/docs/copilot/customization/custom-agents) — Core concepts and getting started
- [Custom Agents Configuration Reference](https://docs.github.com/en/copilot/reference/custom-agents-configuration) — YAML frontmatter schema

### Copilot Tools & Features
- [Copilot Chat Tools](https://code.visualstudio.com/docs/copilot/chat/chat-tools) — Available tools including `#runSubagent`
- [Copilot Features Reference](https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features) — Comprehensive tool catalog

### Customization
- [Prompt Files](https://code.visualstudio.com/docs/copilot/customization/prompt-files) — Reusable prompts with variable interpolation
- [Agent Skills (SKILL.md)](https://code.visualstudio.com/docs/copilot/customization/agent-skills) — Task-specific workflows for agents
- [Instruction Files (.instructions.md)](https://code.visualstudio.com/docs/copilot/customization/instruction-files) — Coding standards and conventions
- [Copilot Hooks (.github/hooks/*.json)](https://code.visualstudio.com/docs/copilot/customization/hooks) — Lifecycle automation and validation

---

## GitHub Documentation

### Concepts
- [About Custom Agents (Coding Agent)](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents) — GitHub's perspective on agents
- [GitHub Copilot Overview](https://docs.github.com/copilot) — Platform-level documentation

### Integration
- [Copilot Extensions](https://docs.github.com/copilot/building-copilot-extensions) — Building agent extensions
- [GitHub Models](https://docs.github.com/en/github-models) — Using GitHub's model catalog

---

## DevOps & Engineering Practices

### CI/CD
- [GitHub Actions Documentation](https://docs.github.com/actions) — Workflow automation
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/learn-github-actions/security-hardening-for-github-actions) — Security and optimization

### Docker & Containers
- [Docker Documentation](https://docs.docker.com/) — Containerization
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/) — Optimizing images

### Observability
- [OpenTelemetry](https://opentelemetry.io/) — Distributed tracing and metrics
- [Prometheus](https://prometheus.io/docs/) — Monitoring and alerting

---

## Security & Compliance

### Standards
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) — Web application security risks
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks) — Security configuration standards
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework) — Risk management

### Frameworks
- [HIPAA Compliance](https://www.hhs.gov/hipaa/for-professionals/security/index.html) — Healthcare data protection
- [SOC 2 Trust Services Criteria](https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/sorhome) — Service organization controls
- [GDPR](https://gdpr.eu/) — EU data privacy regulation

---

## Programming Languages

### Python
- [Python Official Documentation](https://docs.python.org/3/) — Language reference
- [PEP 8 Style Guide](https://peps.python.org/pep-0008/) — Python coding conventions

### Go
- [Go Documentation](https://go.dev/doc/) — Language specification
- [Effective Go](https://go.dev/doc/effective_go) — Idiomatic Go patterns

### JavaScript/TypeScript
- [MDN Web Docs](https://developer.mozilla.org/) — Web platform reference
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html) — Type system and best practices

---

## Testing & Quality

### Testing Frameworks
- [Jest](https://jestjs.io/) — JavaScript testing
- [pytest](https://docs.pytest.org/) — Python testing framework
- [Go Testing](https://go.dev/doc/tutorial/add-a-test) — Built-in testing package

### Test Strategy
- [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html) — Testing strategy framework
- [Mutation Testing](https://en.wikipedia.org/wiki/Mutation_testing) — Test effectiveness measurement

---

## Performance Optimization

### Frontend
- [Web Vitals](https://web.dev/vitals/) — Core web performance metrics
- [Lighthouse](https://developers.google.com/web/tools/lighthouse) — Performance auditing

### Backend
- [Database Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization) — PostgreSQL optimization
- [Profiling Tools Comparison](https://github.com/flamegraph-rs/flamegraph) — Flame graphs

---

## Accessibility

### Standards
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/) — Web Content Accessibility Guidelines
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/) — Accessible Rich Internet Applications

### Tools
- [Accessibility Insights](https://accessibilityinsights.io/) — Automated and manual testing
- [axe DevTools](https://www.deque.com/axe/devtools/) — Accessibility testing extension

---

## Database Engineering

### PostgreSQL
- [PostgreSQL Documentation](https://www.postgresql.org/docs/) — Official reference
- [Use The Index, Luke!](https://use-the-index-luke.com/) — SQL indexing and tuning

### MySQL
- [MySQL Documentation](https://dev.mysql.com/doc/) — Official reference
- [MySQL Performance Blog](https://www.percona.com/blog/) — Optimization insights

---

## SRE & Incident Management

### Principles
- [Google SRE Book](https://sre.google/books/) — Site Reliability Engineering
- [The DevOps Handbook](https://itrevolution.com/product/the-devops-handbook/) — DevOps transformation

### Incident Response
- [PagerDuty Incident Response Guide](https://response.pagerduty.com/) — Best practices
- [Atlassian Incident Management](https://www.atlassian.com/incident-management) — Handbook

---

## Release Management

### Version Control
- [Semantic Versioning](https://semver.org/) — Version number specification
- [Keep a Changelog](https://keepachangelog.com/) — Changelog format

### Deployment Strategies
- [Blue/Green Deployments](https://martinfowler.com/bliki/BlueGreenDeployment.html) — Zero-downtime releases
- [Canary Releases](https://martinfowler.com/bliki/CanaryRelease.html) — Progressive rollouts

---

## Notes

- This list is curated for the Copilot Agent Suite and focuses on authoritative, maintained resources.
- Links are checked as of January 2026 and should be periodically reviewed.
- For agent-specific references, see individual `.agent.md` files.
- When adding new links, verify they're official/primary sources, not third-party tutorials.
- **For detailed code patterns and examples**, see the pattern files in this directory:
  - [docker-patterns.md](docker-patterns.md) - Docker examples and best practices
  - [github-actions-patterns.md](github-actions-patterns.md) - CI/CD workflow examples
  - [a11y-patterns.md](a11y-patterns.md) - Accessibility component patterns
  - [go-patterns.md](go-patterns.md) - Go code examples and idioms
  - [performance-optimization.md](performance-optimization.md) - Performance best practices for all stacks

---

**Last Updated**: January 18, 2026
**Maintainer**: Orchestrator Agent
