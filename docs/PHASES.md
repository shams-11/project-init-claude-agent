# Pipeline phases — detailed flow

This document explains the internal operation of `project-init`: per-phase activity, sub-agent prompts, state schema, validation checks, and the resolver registry.

## High-level flow

```
User invokes /project-init "<idea>"
       │
       ▼
┌────────────────┐
│ Mode detect    │  NEW_PROJECT or NEW_FEATURE
│ Locale detect  │  EN | TR | DE | ... (default EN)
│ State init     │  ~/.claude/state/project-init/<slug>.json
└──────┬─────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ MODE_NEW_PROJECT (11 phases)                             │
│   Phase 0  → Idea capture            (instant)           │
│   Phase 1  → Classification          (auto)              │
│   Phase 2  → Prior-art research      (auto)              │
│   Phase 3  → PRD interview           (interactive)       │
│   Phase 4  → Tech stack proposal     (semi-auto)         │
│   Phase 5  → Component decomposition (auto)              │
│   Phase 6  → Architecture + Security (auto, parallel)    │
│   Phase 7  → Roadmap                  (auto)             │
│   Phase 8  → Repo + scaffold         (semi-auto)         │
│   Phase 9  → Vault hub               (auto)              │
│   Phase 10 → Sprint 1 tasks          (auto)              │
│   Phase 11 → Validation + self-heal  (auto)              │
└──────────────────────────────────────────────────────────┘

       OR

┌──────────────────────────────────────────────────────────┐
│ MODE_NEW_FEATURE (9 phases)                              │
│   Phase F0 → Feature capture          (instant)          │
│   Phase F1 → Classification           (auto)             │
│   Phase F2 → Library / repo research  (auto)             │
│   Phase F3 → Requirements interview   (interactive)      │
│   Phase F4 → Component impact         (auto)             │
│   Phase F5 → Design proposal          (auto)             │
│   Phase F6 → Security review          (auto, conditional)│
│   Phase F7 → Task breakdown           (auto)             │
│   Phase F8 → Feature spec write       (auto)             │
│   Phase F9 → Validation + self-heal   (auto)             │
└──────────────────────────────────────────────────────────┘
       │
       ▼
End-of-run summary, surfaced to user
```

## State schema

```json
{
  "mode": "NEW_PROJECT|NEW_FEATURE",
  "slug": "fitness-tracker",
  "project_name": "Fitness Tracker",
  "user_locale": "en",
  "current_phase": "Phase 4",
  "completed_phases": ["Phase 0", "Phase 1", "Phase 2", "Phase 3"],
  "outputs": {
    "phase_1": {
      "classification": {
        "category": "healthtech",
        "platform": "mobile-first",
        "locale_target": "en-US",
        "monetization_hint": "freemium"
      }
    },
    "phase_2": {
      "prior_art_table": [],
      "build_vs_use_decision": "build novel",
      "differentiator_summary": "..."
    },
    "phase_3": {
      "prd_file": "docs/01-PRD.md",
      "quality_score": 92
    }
  },
  "errors": [],
  "started_at": "2026-01-15T14:32:18Z",
  "updated_at": "2026-01-15T15:08:45Z"
}
```

Atomic write (tempfile + rename) after every phase. On agent re-invocation, glob in-progress state files and prompt for resume.

## Sub-agent context bundle (every delegate call)

Each `Agent()` call passes a structured context bundle to prevent context dilution:

```
[Project context]
- Name: <project>
- Mode: NEW_PROJECT | NEW_FEATURE
- Current phase: Phase <X>
- Tech stack so far: <list>
- Locale: <detected>
- Prior patterns (if vault accessible): <summary>

[Previous phase output — relevant subset only]
<focused summary, not raw dump>

[Your task]
<scoped ask>

[Output format]
<expected structure>
```

## Per-phase details

### Phase 1 — Classification taxonomy

Heuristic keyword match (case-insensitive, multi-language):

| Keywords | Category |
|---|---|
| finance, payment, wallet, budget, banking | fintech |
| health, medical, fitness, wellness, telemedicine | healthtech |
| shop, store, ecommerce, marketplace, retail | e-commerce |
| task, todo, productivity, notes, planner | productivity |
| social, chat, community, messenger, network | social |
| developer, devtool, cli, api, sdk | devtool |
| AI, ML, llm, neural, embedding, model | ai-ml |
| iot, sensor, smart home, embedded | iot |
| game, gaming | gaming |
| education, learn, course, tutoring | edtech |

If no match → ask the user to pick or extend the taxonomy.

### Phase 2 — Prior-art search strategy

3 queries per project:
1. `"best <category> app <year>"`
2. `"<core feature> open source github"`
3. `"<idea> existing solutions comparison"`

Each via `WebSearch(query="...")` capped at top 5. Plus `gh search repos "<category> <core>" --sort=stars --limit=10`.

Coverage scoring (qualitative, agent judgment):
- **>80%** → strongly recommend not building (use/fork/integrate existing)
- **40-80%** → similar projects exist; surface differentiator and continue
- **<40%** → novel; proceed

### Phase 5 — Component decomposition example

For a healthtech mobile-first project with offline + payments + push notifications:

```
Backend:
  auth/      (jwt + refresh + biometric verify)
  api/users/, api/workouts/, api/programs/
  db/        (User, Workout, Program, Subscription tables)
  workers/   (subscription billing daily, push notif daily)
  payments/  (Stripe webhook + recurring)
  notifications/ (push via FCM/APNs)
  storage/   (avatar upload to S3-compatible)
  observability/ (Sentry + structured logs)
  middleware/rate_limit

Frontend (Flutter):
  routes/{home, workouts, programs, profile, paywall}
  components/{atom, molecule, organism}
  state/{auth, workouts, subscription}
  forms/{signup, payment, workout-log}
  theme/{colors, typography, spacing}
  navigation/router
  api/client + interceptors
  l10n/{en, es, ...}

Database:
  users (id, email, locale, biometric_pubkey, created_at)
  workouts (id, user_id, type, duration, calories, started_at)
  programs (id, name, weeks, exercises_json)
  subscriptions (id, user_id, plan, status, stripe_id, renew_at)
  push_tokens (id, user_id, token, platform)
  Indexes: users.email, workouts.user_id+started_at, subs.stripe_id

Infra:
  Docker Compose: api + worker + postgres + redis
  CI: GitHub Actions (lint + test + build per push)
  Monitoring: Sentry for errors + structured logs to file/stdout
  Secrets: .env (dev), vault solution for prod
```

### Phase 8 — Repo creation safeguards

Preflight before `gh repo create`:

```bash
gh auth status                                       # must succeed
gh api rate_limit --jq '.rate.remaining'             # must be ≥ 50
gh repo view "$(gh api user --jq .login)/<slug>" 2>/dev/null
# expect: 404 (name available)
# if found: suggest 3 alternatives, ask user
```

After approval:

```bash
gh repo create <slug> --$VISIBILITY --description "<one-liner>"
git init -b main
git remote add origin "https://github.com/$(gh api user --jq .login)/<slug>.git"
# write scaffold files...
git add . && git commit -m "init: Phase-0 scaffold (PRD + ADRs + components + tech stack)"
git push -u origin main
git checkout -b develop && git push -u origin develop
```

### Phase 11 — Validation checklist

| # | Check | Pass criterion | Resolver if fail |
|---|---|---|---|
| 1 | PRD quality | prp-prd score ≥ 90 | re-invoke prp-prd weak sections |
| 2 | Tech stack ADRs | One ADR file per locked layer | re-invoke architect with missing layer |
| 3 | Architecture | mermaid + ER + API present in docs | re-invoke code-architect |
| 4 | Components | 4 categories covered (backend/frontend/db/infra) | self-fix (add missing) |
| 5 | Security review | Regulation-compliant notes present per locale | re-invoke security-reviewer |
| 6 | Repo created | `gh repo view "$(gh api user --jq .login)/<slug>"` succeeds | gh auth check → retry |
| 7 | Vault hub | `_index.md` exists + Dataview-parseable | self-fix (rewrite from template) |
| 8 | Sprint tasks | TaskList has ≥ 5 tasks | re-invoke planner |

Each failed check loops up to 3 times. After exhausting retries, the agent surfaces a structured failure report to the user with the preserved state file path so the user can fix manually and resume.

### Resolver registry (Phase 11 + F9)

Issue → resolver mapping. The agent inspects the failure type and invokes the appropriate sub-agent with a focused context bundle (error msg + file path + phase + relevant prior output).

| Issue type | Resolver(s) |
|---|---|
| Python build/type errors | `everything-claude-code:python-reviewer` + `build-error-resolver` |
| TS/JS build/type errors | `everything-claude-code:typescript-reviewer` + `build-error-resolver` |
| Dart/Flutter build errors | `everything-claude-code:dart-build-resolver` + `flutter-reviewer` |
| Go build errors | `everything-claude-code:go-build-resolver` + `go-reviewer` |
| Rust build errors | `everything-claude-code:rust-build-resolver` + `rust-reviewer` |
| Kotlin build errors | `everything-claude-code:kotlin-build-resolver` + `kotlin-reviewer` |
| Java/Spring build errors | `everything-claude-code:java-build-resolver` + `java-reviewer` |
| C# errors | `everything-claude-code:csharp-reviewer` |
| C++ build errors | `everything-claude-code:cpp-build-resolver` + `cpp-reviewer` |
| PyTorch runtime errors | `everything-claude-code:pytorch-build-resolver` |
| Security gap | `everything-claude-code:security-reviewer` |
| Silent failure / swallowed error | `everything-claude-code:silent-failure-hunter` |
| Performance issue | `everything-claude-code:performance-optimizer` |
| Dead / duplicate code | `everything-claude-code:refactor-cleaner` |
| Documentation gap | `everything-claude-code:doc-updater` |
| E2E test failure | `everything-claude-code:e2e-runner` |
| Comment rot | `everything-claude-code:comment-analyzer` |
| Type design issue | `everything-claude-code:type-design-analyzer` |

## Constraints applied

| Constraint | Implementation |
|---|---|
| Sub-agent context dilution | Mandatory context bundle per `Agent()` call (no raw dumps) |
| Search depth blow-up | WebSearch top 5 + 1 refine pass; gh search `--limit=10` → filter top 5; Exa max 5 |
| Crash recovery | State file atomic save per phase; resume protocol on next invocation |
| GitHub rate limit | Preflight `gh api rate_limit`; exponential backoff on 5xx; single repo per invocation |
| Locale handling | Detect from prompt → user-language output; ADR titles English (international); sub-agent prompts always English |

## Locale rules summary

| Surface | Language |
|---|---|
| Agent's messages to user | Detected locale |
| ADR file names + titles | English |
| ADR `Context` / `Decision` / `Alternatives` / `Consequences` sections | English (technical precision) |
| ADR `Why` / `How to apply` sections | User's language (intent fidelity) |
| Sub-agent prompts | English (sub-agents are English-native, performance better) |
| README.md (in created repo) | Bilingual (English first, then user-language) |
| Code comments | English (international code review standard) |
| Vault notes (if vault available) | User's language (matches existing vault) |

## State recovery example

If the agent crashes during Phase 5:

```json
{
  "mode": "NEW_PROJECT",
  "slug": "fitness-tracker",
  "current_phase": "Phase 5",
  "completed_phases": ["Phase 0", "Phase 1", "Phase 2", "Phase 3", "Phase 4"],
  "outputs": { "phase_4": { "tech_stack": {} } },
  "started_at": "2026-01-15T14:32:00Z",
  "updated_at": "2026-01-15T15:30:00Z"
}
```

On next `/project-init` invocation, the agent detects the in-progress run and prompts:

```
Found in-progress run from 2026-01-15 14:32 for 'fitness-tracker' at Phase 5.
Resume? (y/n/start fresh)
```

If `y`: resume from Phase 5 using the persisted outputs. If `n`: abandon current and continue with new prompt. If `start fresh`: archive state file and start over.
