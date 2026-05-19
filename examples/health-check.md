# Example: MODE_PROJECT_HEALTH_CHECK (v2.4)

Sample walkthrough of periodic health audit across all your projects.

## Input

```
/project-init --health
```

Or scheduled via `--watch`:
```
/project-init --health --watch
```
(generates a cron entry for daily 09:00 runs)

## What the agent does (abbreviated)

### Phase H0 — Project inventory
> Found 12 active projects (filtered by `--topic=active` if specified)

### Phase H1 — Per-repo health scan (parallel)
> Scanning 12 repos for CI status, commit recency, open issues/PRs, branch hygiene, default branch protection, license presence...

### Phase H2 — Dependency drift (parallel)
> Checking outdated deps and security advisories...
> finance-helper: 3 outdated, 1 advisory (MEDIUM)
> fitness-tracker-weekly: 0 outdated, 0 advisories
> clasycare-web: 8 outdated, 2 advisories (1 HIGH, 1 MEDIUM)
> ...

### Phase H3 — Health scoring
> Per-repo health scores:
>
> | Repo | Score | Tier | Top concern |
> |---|---|---|---|
> | finance-helper | 88 | 🟢 healthy | 1 medium advisory |
> | fitness-tracker-weekly | 95 | 🟢 healthy | — |
> | clasycare-web | 62 | 🟠 at risk | HIGH advisory + 8 outdated |
> | api-gateway | 78 | 🟡 needs attention | 12 stale branches |
> | experiment-graphql | 45 | 🔴 critical | last commit 6 months, no branch protection |

### Phase H4 — Drift detection
> Comparing with previous run (2026-05-13)...
> Changes since last week:
>   - clasycare-web: 88 → 62 (-26) — new HIGH advisory introduced (CVE-2026-XXXX in <lib>)
>   - experiment-graphql: 50 → 45 (-5) — still stale, no improvement
>   - api-gateway: 75 → 78 (+3) — closed 3 stale PRs

### Phase H5 — Recommendations
> Top priority actions:
>
> | Repo | Action | Priority | Effort |
> |---|---|---|---|
> | clasycare-web | Bump `<lib>` to 4.5.2 (fixes CVE) | 🔴 P0 | S |
> | clasycare-web | Update 8 outdated deps (batch) | 🟡 P2 | M |
> | experiment-graphql | Decide: revive or archive | 🟠 P1 | (decision) |
> | api-gateway | Clean up 12 stale branches | 🟢 P3 | S |
>
> Each action → macro + 2-4 micros following the standard task hierarchy.

### Phase H6 — Report + TaskCreate
> Audit report: 02_Areas/project-health/2026-05-20-health.md
> Dashboard: 02_Areas/project-health/_dashboard.md (score history per repo)
> Tasks created: 4 macros, 11 micros
> Webhook notify (if --notify=<slack-url>): "3 repos need attention, 1 critical"

### End-of-run summary

```
🏥 Health check complete — 2026-05-20

Scanned: 12 repos
Healthy 🟢 6  |  Needs attention 🟡 3  |  At risk 🟠 2  |  Critical 🔴 1

Top concerns:
  🔴 clasycare-web: CVE-2026-XXXX HIGH severity advisory (introduced this week)
  🟠 experiment-graphql: last commit 6 months — decide revive vs archive
  🟡 api-gateway: 12 stale branches

Recommendations: 4 priority actions
Report: 02_Areas/project-health/2026-05-20-health.md
Dashboard: 02_Areas/project-health/_dashboard.md
```

### When run via `--watch`
- Generates a cron entry (or launchd / Task Scheduler on macOS / Windows)
- User installs once
- Each daily run produces a report + diff vs previous day
- Weekly digest summary every Monday
- Webhook notify (Slack/Discord) if any repo falls to 🔴 critical
