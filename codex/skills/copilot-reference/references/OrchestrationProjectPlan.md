# Copilot Agent Suite (User Profile) — Project Plan

This project creates an enterprise-style “virtual engineering org” in **VS Code Copilot custom agents**, stored in your **User Profile** (not `.github/`). The core idea is **small, composable agents** coordinated by a lightweight **Orchestrator** that primarily delegates via `#runSubagent`.

The plan is intentionally broken into **small steps** so Copilot doesn’t hit response length limits.

---

## Goals

- Build a **suite of custom agents** in VS Code User Profile.
- Make an **Orchestrator agent** that:
  - Delegates almost everything using `#runSubagent`
  - Synthesizes results and produces a short “decision log”
- Add a few high-value specialists first (TL, SWE, QA, DevOps/SRE, Security, Reviewer).
- Provide a repeatable workflow: **triage → delegate → reconcile → deliver**.

---

## Non-goals (for now)

- Creating every possible role from day 1.
- Building skills/prompt files/MCP integrations immediately.
- Auto-generating a massive reference link compendium in the same run as agent creation.

We’ll do those later once the base agents are stable.

---

## Success criteria

- You can select the **Orchestrator** in Copilot Chat and it reliably:
  - Breaks tasks into subtasks
  - Calls `#runSubagent` with the right specialist
  - Produces a coherent final answer
- Specialists produce consistent outputs (plans, checklists, code changes, test plans).
- No “length limit” failures in normal use.

---

## Where agents live (User Profile)

You’ll create these using VS Code UI:

1. Open Copilot Chat
2. Run **“Chat: New Custom Agent”**
3. Choose **User profile**
4. Name it (ex: “Orchestrator”) and paste the agent file content

This keeps agents in your VS Code profile directory, not the repo.

---

## Project structure (conceptual)

Even though these live in your user profile, keep a matching folder in a local repo for versioning:

copilot-agent-suite/
README.md
agents/
orchestrator.agent.md
tech-lead.agent.md
software-engineer.agent.md
qa-test.agent.md
devops.agent.md
sre.agent.md
security.agent.md
code-reviewer.agent.md
prompts/
orchestrate.prompt.md
review-code.prompt.md
plan-feature.prompt.md
references/
links.md

## Milestones

### Milestone 0 — Baseline Orchestrator (30–60 min)
**Deliverable:** `orchestrator.agent.md` only

**Purpose:** Stop Copilot from trying to do everything itself.

**Key behavior:**
- Always delegates to specialists via `#runSubagent`
- Keeps its own output short
- Uses a consistent response template:
  1) Brief plan
  2) Delegations
  3) Synthesis
  4) Decision log
  5) Next actions

**Acceptance test:**
Ask: “Plan and implement X” → Orchestrator delegates and returns a concise integrated plan.

---

### Milestone 1 — Core Engineering Pod (1–2 hours)
**Deliverables (agents):**
- `tech-lead.agent.md`
- `software-engineer.agent.md`
- `qa-test.agent.md`
- `code-reviewer.agent.md`

**Acceptance tests:**
- Orchestrator + Tech Lead: produces a clean implementation plan
- SWE: produces patch + tests without rewriting unrelated code
- QA: produces test plan + edge cases
- Reviewer: produces structured review (no edits)

---

### Milestone 2 — Ops Pod (1–2 hours)
**Deliverables (agents):**
- `devops-engineer.agent.md` ✅
- `sre.agent.md` ✅
- `security.agent.md` ✅

**Acceptance tests:**
- DevOps: suggests CI/CD steps and safe defaults ✅
- SRE: adds SLO/observability/runbook guidance ✅
- Security: identifies authz/secrets/attack surface risks ✅

---

### Milestone 3 — Customization Specialists (NEW - Completed)
**Deliverables (agents):**
- `agent-builder.agent.md` ✅ (refactored: 472→287 lines, focuses on agents only)
- `skill-builder.agent.md` ✅ (creates SKILL.md files with progressive disclosure)
- `instruction-builder.agent.md` ✅ (authors .instructions.md with glob patterns)
- `hook-builder.agent.md` ✅ (creates .github/hooks/*.json for security validation)

**Acceptance tests:**
- Agent-builder: designs custom agents with handoffs to skill/instruction/hook builders ✅
- Skill-builder: creates portable SKILL.md files for task-specific workflows ✅
- Instruction-builder: generates .instructions.md with YAML frontmatter and applyTo patterns ✅
- Hook-builder: creates JSON hooks for preToolUse security validation and lifecycle automation ✅
- Cross-references: all four agents reference each other via handoffs ✅

---

### Milestone 4 — Prompts that keep outputs small (45–90 min)
**Deliverables (prompt files):**
- `orchestrate.prompt.md` ✅ — forces delegation and concise synthesis
- `plan-feature.prompt.md` — produces requirements + design + plan
- `review-code.prompt.md` ✅ — standard review format

**Acceptance tests:**
- Running prompt results in stable, predictable format
- No length-limit errors

---

### Milestone 5 — Reference links + optional expansions (Complete) ✅
**Deliverables:**
- `references/links.md` with curated official docs ✅
- `references/docker-patterns.md` - Complete Docker code examples ✅
- `references/github-actions-patterns.md` - Workflow examples ✅
- `references/a11y-patterns.md` - Component patterns ✅
- `references/go-patterns.md` - Go code examples ✅
- Optional roles (DBA, Performance, Release Manager, Incident Commander, Compliance) ✅
- **Optimized instruction files** - Reduced from 3,273 → 1,803 lines (45% reduction) ✅

---

## Work breakdown (the “do this next” list)

### Step 1: Create Orchestrator agent (first)
**Copilot prompt (small):**
- “Create `orchestrator.agent.md` for a VS Code custom agent. Keep it under 120 lines. It must use `#runSubagent` for specialist work and include a short response template.”

Paste result into VS Code agent creation UI.

### Step 2: Create Tech Lead agent
**Prompt:**
- “Create `tech-lead.agent.md`. Keep under 120 lines. Output: implementation plan, boundaries, risks, and ‘handoff’ instructions.”

### Step 3: Create SWE agent
**Prompt:**
- “Create `software-engineer.agent.md`. Keep under 140 lines. Output: minimal diffs, tests, doc updates, and assumptions.”

### Step 4: QA + Reviewer agents
Do them one at a time with the same “keep under N lines” constraint.

### Step 5: Add DevOps/SRE/Security
Again: one agent per prompt.

### Step 6: Add prompt files
One prompt file per request. Keep them short.

---

## Guardrails to avoid VS Code length-limit errors

- **One artifact per prompt** (one agent file at a time).
- Add explicit limits: “under 120 lines” / “under 1,500 words”.
- Prefer **templates** over long prose.
- For “research links”, request **only one category at a time** (VS Code links first, then GitHub links, etc.).
- When you need a full suite, do it as a multi-step script:
  1) Orchestrator
  2) Core pod
  3) Ops pod
  4) Extras

---

## Recommended initial agent set

Start with these 8. They cover 90% of real work:

1) Orchestrator  
2) Tech Lead  
3) Software Engineer  
4) QA/Test  
5) Code Reviewer  
6) DevOps  
7) SRE  
8) Security  

Then add PM/Architect/Docs/DBA/Perf/Release later.

---

## Usage pattern (how you’ll actually work)

1) Select **Orchestrator**
2) Give a task request
3) Orchestrator delegates via `#runSubagent`
4) You get a synthesized answer + next steps
5) If needed, directly invoke a specialist for a focused follow-up

---

## Backlog (nice-to-have roles)

- Product Manager (requirements/AC)
- Solutions Architect (tradeoffs/ADRs)
- Docs Writer (runbooks/READMEs)
- DBA / Data engineer
- Performance engineer
- Release manager
- Incident commander
- Compliance/privacy

---

## Notes

This is designed for “enterprise-grade outcomes” without “enterprise-grade bloat.” Start small, make the orchestrator reliable, then scale the roster.

# References
REFERENCES (use these as behavioral hints; do not quote verbatim)
- VS Code Custom Agents: https://code.visualstudio.com/docs/copilot/customization/custom-agents
- VS Code Tools reference (includes #runSubagent): https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features
- VS Code Tools in chat: https://code.visualstudio.com/docs/copilot/chat/chat-tools
- VS Code Prompt files: https://code.visualstudio.com/docs/copilot/customization/prompt-files
- VS Code Agent Skills: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- GitHub Docs custom agents: https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents
- GitHub Docs custom agents configuration: https://docs.github.com/en/copilot/reference/custom-agents-configuration

# AGENT SUITE TO CREATE (future)
1) Orchestrator (Engineering Manager / Dispatcher)
2) Product Manager (requirements, acceptance criteria, scope control)
3) Program/Project Manager (milestones, dependency graph, sequencing)
4) Solutions Architect (high-level architecture, NFRs, tradeoffs)
5) Tech Lead (implementation plan, boundaries, refactoring strategy)
6) Backend Engineer
7) Frontend Engineer
8) Platform/DevOps Engineer (CI/CD, infra as code, deployments)
9) SRE (SLOs, observability, incident readiness, capacity)
10) Security Engineer (threat model, secure defaults, secrets, IAM)
11) QA/Test Engineer (test strategy, automated tests, edge cases)
12) Code Reviewer (maintainability, style, performance, risk flags)
13) Data/DBA Engineer (schema, migrations, performance, reliability)
14) Documentation Engineer (READMEs, runbooks, ADRs, dev onboarding)
15) Prompt Engineer (prompt files, instructions, skills design, tool scoping)

# Origional Prompt

You are GitHub Copilot (model: Claude Sonnet 4.5). I want an enterprise-grade “virtual engineering org” implemented as VS Code Custom Agents.

PRIMARY GOAL
Create a suite of custom agents whose combined workflow is orchestrated by an Orchestrator agent that heavily uses the tool #runSubagent (and ONLY delegates; the Orchestrator itself should avoid deep work and avoid code edits). The Orchestrator’s job is to route tasks to specialists and then synthesize results.

HARD CONSTRAINTS
- These custom agents must be “User profile” agents (not workspace `.github/agents`).
- Output the final result as a list of files with full contents for each: one code block per file.
- Each file must be a `.agent.md` with YAML frontmatter that includes at minimum: name, description, tools, infer, and (optionally) handoffs.
- Assume the editor supports the #runSubagent tool and common VS Code chat tools like #readFile, #search, #runCommands, #runTests, etc.
- The Orchestrator agent must:
  - Always use #runSubagent for specialist work.
  - Limit itself to triage, delegation, and synthesis.
  - Maintain a “decision log” section in its response.
  - Ask for missing requirements ONLY if genuinely blocking.
- Specialist agents should be usable as subagents (infer: true), and each should be narrowly scoped.

REFERENCES (use these as behavioral hints; do not quote verbatim)
- VS Code Custom Agents: https://code.visualstudio.com/docs/copilot/customization/custom-agents
- VS Code Tools reference (includes #runSubagent): https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features
- VS Code Tools in chat: https://code.visualstudio.com/docs/copilot/chat/chat-tools
- VS Code Prompt files: https://code.visualstudio.com/docs/copilot/customization/prompt-files
- VS Code Agent Skills: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- GitHub Docs custom agents: https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents
- GitHub Docs custom agents configuration: https://docs.github.com/en/copilot/reference/custom-agents-configuration

AGENT SUITE TO CREATE (minimum)
1) Orchestrator (Engineering Manager / Dispatcher)
2) Product Manager (requirements, acceptance criteria, scope control)
3) Program/Project Manager (milestones, dependency graph, sequencing)
4) Solutions Architect (high-level architecture, NFRs, tradeoffs)
5) Tech Lead (implementation plan, boundaries, refactoring strategy)
6) Backend Engineer
7) Frontend Engineer
8) Platform/DevOps Engineer (CI/CD, infra as code, deployments)
9) SRE (SLOs, observability, incident readiness, capacity)
10) Security Engineer (threat model, secure defaults, secrets, IAM)
11) QA/Test Engineer (test strategy, automated tests, edge cases)
12) Code Reviewer (maintainability, style, performance, risk flags)
13) Data/DBA Engineer (schema, migrations, performance, reliability)
14) Documentation Engineer (READMEs, runbooks, ADRs, dev onboarding)
15) Prompt Engineer (prompt files, instructions, skills design, tool scoping)

OPTIONAL “NICE TO HAVE” AGENTS (add if useful)
- Compliance/Privacy (HIPAA/SOC2-ish thinking, audit artifacts)
- FinOps (cloud cost + scaling economics)
- Incident Commander (game-day & incident process)

TOOLS POLICY
- Orchestrator tools: must include runSubagent and read-only-ish tools. Do NOT include tools that encourage direct code edits; instruct it not to edit.
- Specialists: choose minimal tools per role. For example:
  - QA gets runTests, search, readFile
  - DevOps gets runCommands/runTasks, readFile, search
  - Security gets search, readFile, (optional) fetch if web fetching is supported
  - Code Reviewer gets readFile, search, usages
- Keep tool lists short and role-appropriate.

HANDOFFS
Add handoffs where it makes sense:
- Orchestrator -> PM (refine requirements)
- Orchestrator -> Architect (architecture proposal)
- Orchestrator -> TL (implementation plan)
- TL -> Backend/Frontend (implement)
- Implementers -> Code Reviewer & Security & QA
- QA -> SRE (operability review)
- Docs -> final packaging

OUTPUT FORMAT
For each file:
- Start with: “FILE: <filename>.agent.md”
- Then provide the entire file content in a fenced markdown block.

NAMING
Use simple kebab-case filenames, e.g.:
- orchestrator.agent.md
- product-manager.agent.md
- solutions-architect.agent.md
…etc.

NOW DO IT.
Generate the full agent suite with practical, high-quality instructions in each agent body.
Make the Orchestrator’s body include a repeatable workflow template that it follows every time (triage -> delegate via #runSubagent -> reconcile -> decision log -> handoffs).
