# Example: NEW_PROJECT — Mobile fitness tracker

This is a sample walkthrough of `/project-init` building a new project from a one-line idea.

## Input

```
/project-init "build a mobile fitness tracker with weekly summaries"
```

## What the agent does (abbreviated)

### Phase 0 — Idea capture
> Starting: "build a mobile fitness tracker with weekly summaries"
> Mode: NEW_PROJECT, Locale: en

### Phase 0.5 — Pre-PRD setup
> Quick sanity check: Is this project legal? Any privacy/safety concerns? (y/concerns)
> User: y
> Budget tier? (hobby / startup / enterprise)
> User: startup
> Team size? (solo / small / larger)
> User: solo

### Phase 1 — Classification
> 📊 Classification: healthtech / mobile-first / en-US / freemium-hint
> Confirm? (y/n)
> User: y

### Phase 2 — Prior art research
> Top similar projects found:
> | Name | Coverage | Gap |
> |---|---|---|
> | Strava | 70% | No nutrition tracking, paywall heavier than yours |
> | FitBit | 65% | Hardware-only, no software-first option |
> | MyFitnessPal | 60% | Different niche (nutrition-first) |
>
> 📚 Similar projects exist, none cover fully. Gap: weekly-summary-first UX. Continue? (y/n)
> User: y

### Phase 2.5 — Domain & name validation
> Suggested slug: `fitness-tracker-weekly`
> GitHub: available ✅
> npm: available ✅
> pypi: not relevant (mobile)
> Domain hint: fitness-tracker-weekly.com seems available — verify with registrar.
> Continue? (y/n)
> User: y

### Phase 3 — PRD interview
> (delegated to `prp-prd` skill — 10-15 questions)
> ... user answers ...
> PRD saved to `docs/01-PRD.md` (quality score: 92/100 ✅)

### Phase 4 — Tech stack proposal
> Reading prior user projects from vault ...
> Proposal:
> - Mobile: Flutter + Riverpod + Drift (offline-first)
> - Backend: FastAPI + SQLAlchemy 2.0 async + Postgres 16
> - Auth: Custom JWT + refresh + biometric
> - Storage: S3-compatible (R2 or similar)
> - Hosting: small VPS with managed orchestrator
>
> Lock each? (y/n/alt N per layer)

### Phase 5 — Component decomposition
> Backend: auth, api/users, api/workouts, api/programs, db, workers/weekly-summary, observability
> Frontend: routes (dashboard, workouts, programs, profile, paywall), components, state, theme, l10n
> Database: users, workouts, programs, subscriptions, push_tokens
> Infra: Docker Compose, Postgres, Redis, CDN, error tracking, GitHub Actions

### Phase 6 — Architecture + Security (parallel)
> Architecture: mermaid system diagram + ER + API list
> Security: STRIDE-lite threat model, JWT rotation, GDPR data handling
> Outputs: docs/03-ARCHITECTURE.md, docs/04-DATA-MODEL.md, docs/06-SECURITY.md

### Phase 7 — Roadmap
> Phase 1: backend scaffold + auth (M, 2 weeks)
> Phase 2: workout CRUD + DB (M, 1.5 weeks)
> Phase 3: mobile shell + auth flow (L, 2 weeks)
> ...
> MVP target: 2026-09

### Phase 7.5 — Cost estimation
> VPS: $5/mo
> Postgres on VPS: included
> Object storage: ~$1/mo (small)
> Error tracking free tier: $0
> AI APIs (workout coaching): ~$30/mo (estimated)
> Domain: $15/yr
> Apple Dev: $99/yr
> Google Play: $25 one-time
>
> Total: $36/mo, $501 Year 1 — aligns with startup tier ✅

### Phase 8 — Repo creation & scaffold
> Preview:
>   slug: fitness-tracker-weekly
>   visibility: private
>   structure: monorepo (mobile/ + backend/)
>   files to create: 24
>   license: (private — skip)
>   Proceed? (y/n)
> User: y
>
> ... gh repo create ... git init ... scaffold ... initial commit ... push ... develop branch ...
> ✅ Repo: https://github.com/<user>/fitness-tracker-weekly

### Phase 9 — Vault hub
> 01_Projects/fitness-tracker-weekly/_index.md written
> ADRs copied to decisions/
> _init-log.md initialized

### Phase 10 — Sprint 1 tasks (micronized)
> Macro #M1: Set up backend skeleton (Σ 4h)
>   ├── Micro #m1.1 [parallel] Initialize FastAPI app with /healthz endpoint
>   ├── Micro #m1.2 [parallel] Configure Alembic + first empty migration
>   ├── Micro #m1.3 [blocked-by: #m1.1] Add CORS middleware + structured logger
>   └── Micro #m1.4 [blocked-by: #m1.2] Wire Postgres connection + retry
>
> Macro #M2: Implement user auth (Σ 6h)
>   ├── Micro #m2.1 [parallel] Define User SQLAlchemy model
>   ├── Micro #m2.2 [parallel] Add Alembic migration 0001_create_users
>   ├── Micro #m2.3 [blocked-by: #m2.1] Implement password_hash(plain) via argon2
>   ├── Micro #m2.4 [blocked-by: #m2.2, #m2.3] Define LoginRequest/Response Pydantic schemas
>   └── Micro #m2.5 [blocked-by: #m2.4] Implement POST /auth/login route + unit test
>
> ... (5 more macros) ...
>
> Total: 7 macros, 31 micros, ~28h estimated.
> sprints/01-kickoff.md written.

### Phase 11 — Validation + self-healing
> All checks pass. ✅

### End-of-run summary

```
🎉 Phase 0 package ready: Fitness Tracker Weekly

Created:
  📁 Repo: https://github.com/<user>/fitness-tracker-weekly
  📂 Local: $PROJECTS_ROOT/fitness-tracker-weekly/
  📚 Vault: 01_Projects/fitness-tracker-weekly/
  📊 Classification: healthtech / mobile-first / en-US
  💰 Cost estimate: $36/mo (tier: startup ✅)
  🏗 Components: backend (7 domains), frontend (9 domains), db (5 tables), infra (4 services)
  ✅ Sprint 1: 31 micro tasks across 7 macros (~28h)

Next steps:
  1. cd $PROJECTS_ROOT/fitness-tracker-weekly && claude
  2. Review docs/00-DECISIONS-LOCKED.md
  3. Pick #m1.1 or #m1.2 (parallel-safe starting micros)
```
