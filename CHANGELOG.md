# Changelog

All notable changes to `project-init` will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/).

## [2.1.0] — 2026-01

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

## [2.0.0] — 2026-01

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
