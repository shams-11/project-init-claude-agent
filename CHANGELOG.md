# Changelog

All notable changes to `project-init` will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/).

## [2.3.0] — 2026-05-20

### Added — Micronized task breakdown (cross-cutting)

All task-generating phases (Phase 10 Sprint 1, Phase F7 Feature tasks, Phase R6 Repo audit recommendations, Phase A6 Agent audit recommendations) now produce a **2-tier task hierarchy** instead of a flat list:

- **Tier 1 — Macro tasks** (2-8 hours, outcome-oriented): 3-15 per phase
- **Tier 2 — Micro tasks** (15-45 minutes, atomic): 2-8 per macro, with:
  - Verb + specific output title (e.g., "Define User SQLAlchemy model with email/password_hash/created_at")
  - 1-line testable acceptance criterion
  - Sequential / parallel marker
  - Dependency list (`blocked-by: #<ids>`)

### Added — Dependency graph surface

After task creation, the agent surfaces a tree visualization marking parallel-safe siblings and sequential chains. Operators can identify the critical path and parallelize Sprint 1 across siblings.

### Added — Effort consistency check

Macro effort estimate must equal sum of constituent micros (within 30% tolerance). Mismatch → automatic re-decomposition.

### Changed

- Phase 10, F7, R6, A6 sub-agent (planner) prompts updated to request 2-tier output
- `TaskCreate` descriptions now include `Parent: #<id>`, `Blocked-by: #<list>`, `Parallel-safe: yes|no`
- Sprint kickoff doc (`sprints/01-kickoff.md`) renders the full 2-tier tree

### Rationale

Operators reported difficulty parallelizing Sprint 1 work with flat hour-long tasks. Micro-task granularity enables:
- Fine-grained progress tracking
- Parallel execution across team members or claude sessions
- Easier context-switching during async work
- More accurate effort estimation via composition

## [2.2.0] — 2026-05-20

### Added — Two new modes

- **MODE_CROSS_REPO_AUDIT** (7 phases R0-R6): scans all of the user's repos from GitHub + local `$PROJECTS_ROOT` + Obsidian vault, detects functional overlap and duplication, and proposes organization (shared library extraction, monorepo consolidation, cross-repo refactor PR plan, dependency alignment, external dependency monitoring with risk flags). Optional Phase R7 executes approved actions as PRs with strict per-item approval.
- **MODE_CROSS_AGENT_AUDIT** (7 phases A0-A6): scans all installed AI sub-agents (user-level `~/.claude/agents/`, plugin-provided, project-local), builds a delegate topology, and surfaces functional overlap, orphan agents, naming inconsistencies, tool over-scoping, broken references, and consolidation opportunities. Optional Phase A7 archives (never hard-deletes) approved consolidations with strict per-item approval. Plugin-provided agents are always read-only.

### Added — Phases

#### MODE_CROSS_REPO_AUDIT (R0-R6)
- **R0** Repo discovery (GitHub `gh repo list` + local `$PROJECTS_ROOT` scan + vault `01_Projects/` glob)
- **R1** Repo profiling (parallel) — language, structure, dependencies, open issues/PRs, topics
- **R2** Similarity matrix — pairwise scoring on shared deps + topics + naming + tech stack + folder structure
- **R3** Duplication detection — filename matches + distinctive function search + shared utility patterns
- **R4** Organization recommendations — shared library extraction, monorepo consolidation, dependency alignment, cross-repo refactor PR plan, topic/metadata alignment
- **R5** External dependencies map — top 20 most-used + maintenance signal + risk flags + engagement suggestions
- **R6** Action plan + audit report + TaskCreate (+ optional R7 execute with approval)

#### MODE_CROSS_AGENT_AUDIT (A0-A6)
- **A0** Agent discovery (user + plugin + project + vault sources)
- **A1** Agent profiling — name, description, tools, model, domain inference, delegate edges, system prompt length
- **A2** Similarity matrix — description overlap + tool overlap + domain overlap + name similarity
- **A3** Duplication detection — system prompt comparison + responsibility overlap detection + naming inconsistency flags
- **A4** Cross-agent communication map — delegate topology + hub agents + orphan agents + circular delegations + broken references
- **A5** Organization recommendations — consolidate, hierarchy clarification, naming standardization, tool scope reduction, broken reference fixes, promote/demote, cross-plugin overlap resolution
- **A6** Action plan + audit report + TaskCreate (+ optional A7 archive-based execute with approval)

### Changed

- Frontmatter description updated to reflect 4 modes
- Mode detection table extended with audit mode triggers (English + Turkish keywords + `--audit-repos` / `--audit-agents` flags)
- Total pipeline now covers 14 + 10 + 7 + 7 = **38 distinct phases** across 4 modes

### Safety

- Cross-repo audit Phase R7 (execute): NEVER pushes to main directly; opens PRs with audit-report context
- Cross-agent audit Phase A7 (execute): archive-then-restore over hard delete; plugin agents never mutated
- Both require explicit per-item user approval

## [2.1.0] — 2026-05-19

### Added — NEW_PROJECT mode

- **Phase 0.5 — Pre-PRD setup** (interactive): idea-validation gate (legal/ethical), budget tier (hobby/startup/enterprise), team size profile
- **Phase 2.5 — Domain & name validation**: GitHub repo + npm/PyPI/crates.io/pub.dev conflict checks + domain hint search + trademark hint
- **Phase 7.5 — Cost estimation**: monthly + annual cost projection across hosting/db/storage/AI APIs/email/push/monitoring/analytics/domain/CI; aligns with chosen budget tier
- **Phase 8 sub-steps** (8a-8m, enhanced scaffold):
  - 8c License selection wizard (MIT / Apache-2.0 / GPL-3.0 / AGPL-3.0 / MPL-2.0 / BSL / ISC for public)
  - 8f Language-specific CI workflow templates (Python, Node/TS, Dart, Go, Rust)
  - 8g Standard `.github/` content: PR template + 3 issue templates (bug / feature / question) + Dependabot + CodeQL + CODEOWNERS
  - 8h Pre-commit hooks setup per language (pre-commit framework, Husky + lint-staged, Lefthook)
  - 8i Multi-environment configs (`.env.example`, `.env.staging.example`, `.env.production.example`)
  - 8j Polish files: `.editorconfig`, `.gitattributes`, README badges, CHANGELOG.md init
  - 8l Branch protection rules via gh API (auto-apply with user approval)
  - 8m Repo topics for discoverability
- **Phase 6 supplementary ADRs**: deployment-strategy + backup-disaster-recovery
- **Phase 11 validation extensions**: accessibility (a11y-architect), frontend design (frontend-design), database design (database-reviewer), API design (api-design skill), healthcare compliance (healthcare-reviewer), test coverage plan (pr-test-analyzer)

### Added — NEW_FEATURE mode

- **Phase F2.5 — Cost impact estimation**: marginal cost analysis when feature introduces new library/service; updates project cost estimate

### Added — Cross-cutting

- New env var `PROJECT_INIT_BUDGET_TIER` (hobby / startup / enterprise)
- New supporting doc `docs/SCAFFOLD_CHECKLIST.md` with copy-ready templates for every scaffold artifact (CI workflows per language, pre-commit configs, issue templates, Dependabot YAML, CodeQL workflow, CODEOWNERS, branch protection commands, README badges, license notices, multi-env configs)

### Changed

- NEW_PROJECT pipeline expanded from 11 to **14 phases** (added 0.5, 2.5, 7.5; Phase 8 internal sub-steps formalized)
- NEW_FEATURE pipeline expanded from 9 to **10 phases** (added F2.5)
- Resolver registry expanded from 19 to **24 entries** (added a11y, frontend-design, database-reviewer, healthcare-reviewer, pr-test-analyzer)
- Validation checklist expanded from 8 to **16 checks**

## [2.0.0] — 2026-05-19

### Added

- Two-mode operation: `MODE_NEW_PROJECT` (11 phases) and `MODE_NEW_FEATURE` (9 phases)
- Phase 1 — Project classification (taxonomy match: fintech / healthtech / e-commerce / productivity / social / devtool / ai-ml / iot / gaming / edtech)
- Phase 2 — Prior-art research (WebSearch + gh search; coverage scoring with build vs fork vs use decision)
- Phase 5 — Component decomposition (backend / frontend / db / infra compartment tree)
- Phase 11 — Validation + self-healing loop with 19 resolver mappings (build errors per language, security, silent failures, dead code, etc.)
- Sub-agent context bundle pattern (prevents context dilution)
- State persistence + crash recovery (`~/.claude/state/project-init/<slug>.json`)
- GitHub rate limit preflight + exponential backoff
- Locale detection + bilingual output (user-facing in detected locale; ADR titles / sub-agent prompts always English)
- Search depth bounds (top 5 + 1 refine pass)

### Initial release of the public agent

- Single Markdown agent file (`agent/project-init.md`)
- Cross-platform install scripts (`scripts/install.sh` for Linux/macOS; `scripts/install.ps1` for Windows)
- Documentation: README, CONTRIBUTING, docs/PHASES.md
- MIT license
