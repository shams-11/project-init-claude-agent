# project-init — A semi-autonomous lifecycle orchestrator agent for Claude Code

> Turn a one-line project idea (or feature request) into a complete Phase-0 package: PRD, tech stack, architecture, security review, GitHub repo with scaffold, optional Obsidian vault hub, and Sprint-1 task list — through an 11-phase pipeline with self-healing validation.

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Agent-orange.svg)](https://docs.anthropic.com/claude/docs/claude-code)

## What it does

`project-init` is a [Claude Code](https://docs.anthropic.com/claude/docs/claude-code) sub-agent that operates in two modes:

### MODE_NEW_PROJECT (14 phases)

```
Idea → Pre-PRD setup (validation + budget + team) → Classification → Prior-art research →
Domain & name validation → PRD interview → Tech stack proposal → Component decomposition →
Architecture + Security (parallel) → Roadmap → Cost estimation → Repo + scaffold (enhanced) →
Vault hub → Sprint-1 tasks → Validation + self-healing
```

### MODE_NEW_FEATURE (10 phases)

```
Feature capture → Classification → Library/repo research → Cost impact →
Requirements interview → Component impact → Design proposal → Security review →
Task breakdown → Spec write → Validation + self-healing
```

## Why use it?

- **One command** replaces 8+ separate workflow steps
- **Phase 2 prior-art search** prevents wasted effort on solved problems
- **Phase 2.5 domain & name validation** catches naming conflicts (npm/PyPI/GitHub) early
- **Phase 5 component decomposition** auto-breaks projects into backend/frontend/db/infra compartments
- **Phase 7.5 cost estimation** projects monthly + annual cost from tech stack vs budget tier
- **Phase 8 enhanced scaffold** writes language-appropriate CI, Dependabot, CodeQL, pre-commit hooks, issue templates, branch protection, license, multi-env configs, badges
- **Phase 11 self-healing** routes failures to 24 specialized resolver agents (build errors, security gaps, dead code, accessibility, database design, healthcare compliance, etc.)
- **State persistence** across crashes — resume from any phase
- **Locale-aware** — detects user's language, outputs in their language while keeping ADRs international (English)
- **Vault-integrated** (optional) — auto-creates Obsidian project hub for long-term memory
- **Configurable budget tier** — proposals biased toward hobby / startup / enterprise tier

## Prerequisites

| Tool | Required | Purpose |
|---|---|---|
| [Claude Code](https://docs.anthropic.com/claude/docs/claude-code) | ✅ | Runs the agent |
| everything-claude-code (ECC) plugin | ✅ | Provides sub-agents (planner, architect, code-architect, security-reviewer, build-resolvers, prp-prd skill) |
| [`gh` CLI](https://cli.github.com/) | ✅ (Phase 8) | GitHub repo creation |
| Authenticated GitHub user (`gh auth login`) | ✅ (Phase 8) | Push permissions |
| [Obsidian](https://obsidian.md/) | ⚪ (Phase 9) | Vault hub integration |

## Installation

### Option 1: Manual (cross-platform, recommended)

1. Clone or download this repo.
2. Copy the agent file to your Claude Code agents directory:

   **Linux/macOS:**
   ```bash
   mkdir -p ~/.claude/agents
   cp agent/project-init.md ~/.claude/agents/
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\agents" | Out-Null
   Copy-Item agent\project-init.md "$env:USERPROFILE\.claude\agents\"
   ```

3. Restart Claude Code (close and reopen).

4. (Optional) Configure environment variables in your shell:

   ```bash
   export OBSIDIAN_VAULT="$HOME/Documents/MyVault"   # if you use Obsidian
   export PROJECTS_ROOT="$HOME/dev"                   # where to clone new repos
   export PROJECT_INIT_VISIBILITY="private"           # private | public
   ```

### Option 2: Install script

**Linux/macOS:** `bash scripts/install.sh`
**Windows:** `pwsh scripts/install.ps1`

## Usage

### Start a new project

```
claude
> /project-init "build a fitness tracker mobile app"
```

The agent will:
1. Classify it (likely `healthtech / mobile-first`)
2. Search for similar/existing apps (Strava, FitBit, etc.)
3. Run an interactive PRD interview
4. Propose a tech stack
5. Break the project into components
6. Generate architecture + security + roadmap
7. Ask for approval, then create a private GitHub repo with scaffold
8. (Optional) Create an Obsidian vault hub
9. Open Sprint-1 tasks in the task list
10. Validate everything and auto-fix issues via resolver agents

### Add a feature to an existing project

```
claude
> /project-init "add receipt OCR scanning to my finance app"
```

The agent will:
1. Detect the target project (asks if ambiguous)
2. Classify the feature (integration / full-stack / medium risk)
3. **Research libraries** — Tesseract, ML Kit, Google Vision, AWS Textract, etc. — scored by stars, license, recency, compatibility
4. Recommend a primary + fallback library
5. Interview you for requirements
6. Analyze backend/frontend/db/infra impact
7. Propose design
8. Security review (since OCR + file upload is medium risk)
9. Break into 3-10 atomic tasks

### Resume an interrupted run

If a previous run was interrupted, the agent detects it on startup:

```
> /project-init "...new idea..."

Found in-progress run from 2026-05-19 for 'my-prev-project' at Phase 5.
Resume? (y/n/start fresh)
```

## Configuration

| Env var | Default | Purpose |
|---|---|---|
| `OBSIDIAN_VAULT` | `~/Documents/ObsidianVault` (Linux/macOS) or `%USERPROFILE%\Documents\ObsidianVault` (Windows) | Vault path for Phase 9 / Phase F-* project lookup. If not found, vault phases skip with a warning. |
| `PROJECTS_ROOT` | `~/projects` or `%USERPROFILE%\projects` | Where to clone created repos locally |
| `PROJECT_INIT_VISIBILITY` | `private` | Default GitHub repo visibility |
| `PROJECT_INIT_VAULT_STRUCTURE` | `PARA` | Vault folder convention |
| `PROJECT_INIT_BUDGET_TIER` | `startup` | Budget target (`hobby` / `startup` / `enterprise`) — biases tech stack proposal + cost estimate |

## Sub-agent dependencies

The agent delegates specialized work to these ECC sub-agents (must be installed via the ECC plugin):

| Phase | Sub-agent |
|---|---|
| 3 (PRD interview) | `everything-claude-code:prp-prd` (skill) |
| 4 (tech stack) | `everything-claude-code:architect` |
| 6 (architecture) | `everything-claude-code:code-architect` |
| 6 (security) | `everything-claude-code:security-reviewer` |
| 7, 10, F7 (planning) | `everything-claude-code:planner` |
| 11 / F9 (validation resolvers) | 24 resolvers — see [docs/PHASES.md](docs/PHASES.md) |

## Architecture & detailed pipeline

- [docs/PHASES.md](docs/PHASES.md) — full per-phase flow with sub-agent prompts, state schema, validation checklist, and resolver registry
- [docs/SCAFFOLD_CHECKLIST.md](docs/SCAFFOLD_CHECKLIST.md) — copy-ready templates for every scaffold artifact (CI workflows per language, pre-commit configs, issue templates, Dependabot YAML, CodeQL workflow, CODEOWNERS, branch protection commands, README badges, license notices, multi-env configs)
- [CHANGELOG.md](CHANGELOG.md) — version history

## Customization

The agent is a single Markdown file (`agent/project-init.md`). Fork the repo and edit the system prompt to:

- Add new project categories to the Phase 1 taxonomy
- Bias the tech stack proposal toward your own preferred stack
- Add custom validation checks in Phase 11
- Map issue types to your team's own resolver sub-agents
- Change the vault folder convention (PARA vs Zettelkasten vs custom)

## Inspirations & related work

- [Anthropic Claude Code](https://docs.anthropic.com/claude/docs/claude-code)
- [PARA method](https://fortelabs.com/blog/para/) for vault organization
- [Architecture Decision Records (ADR)](https://github.com/joelparkerhenderson/architecture-decision-record)
- [STRIDE threat modeling](https://en.wikipedia.org/wiki/STRIDE_(security))

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
