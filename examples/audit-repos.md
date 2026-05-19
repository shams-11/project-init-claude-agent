# Example: MODE_CROSS_REPO_AUDIT

Sample walkthrough of scanning all your repos for duplication and organization opportunities.

## Input

```
/project-init --audit-repos
```

## What the agent does (abbreviated)

### Phase R0 — Repo discovery
> Discovering repos from GitHub + local + vault...
> Found: 12 repos
>   - GitHub: 10
>   - Local only: 1 (experiment-graphql)
>   - Vault-tracked: 8

### Phase R1 — Repo profiling (parallel)
> Profiling 12 repos in parallel...
> Done. Languages: Python (5), Dart (3), TypeScript (2), Rust (1), Go (1)

### Phase R2 — Similarity matrix
> Top 5 similar pairs (score ≥ 50):
>
> | Pair | Score | Reason |
> |---|---|---|
> | finance-helper + fitness-tracker-weekly | 78 | Both Flutter + FastAPI + Postgres; shared auth/jwt patterns |
> | finance-helper + clasycare-web | 65 | Both FastAPI + Postgres; shared rate-limit middleware |
> | api-gateway + experiment-graphql | 55 | Both TypeScript; both implement custom retry logic |
> | tools-cli-a + tools-cli-b | 75 | Both Go; both wrap same external API |
> | reporting-service + analytics-worker | 60 | Both Python; shared date parsing utilities |

### Phase R3 — Duplication detection
> Detected duplications:
>
> Cluster 1 (auth/jwt): finance-helper, fitness-tracker-weekly, clasycare-web
>   - 3 repos contain near-identical `auth/jwt.py` (~120 lines each)
>   - Estimated 360 lines of duplicated code
>
> Cluster 2 (date utilities): reporting-service, analytics-worker, finance-helper
>   - 3 repos contain similar `utils/date_parse.py`
>   - Estimated 180 lines of duplicated code
>
> Cluster 3 (rate-limit middleware): finance-helper, clasycare-web
>   - 2 repos with similar token-bucket implementation
>   - Estimated 80 lines of duplicated code

### Phase R4 — Organization recommendations
> Top recommendations:
>
> | Rec | Type | Effort | Impact | Risk |
> |---|---|---|---|---|
> | Extract `<user>-py-auth-utils` private package (from 3 repos' auth/jwt) | Shared library | L (8h) | H | Low |
> | Extract `<user>-py-date-utils` (from 3 repos) | Shared library | M (4h) | M | Low |
> | Align lodash versions (4.17, 4.21, 5.0 across TS repos) | Dep alignment | S (2h) | M | Low |
> | Consider merging tools-cli-a + tools-cli-b into mono-cli | Monorepo consolidation | XL (16h) | H | Medium |

### Phase R5 — External dependencies map
> Top 10 most-used external dependencies:
>
> | Library | Used in | Status |
> |---|---|---|
> | fastapi | 4 repos | ✅ active |
> | sqlalchemy | 4 repos | ✅ active |
> | flutter (sdk) | 3 repos | ✅ active |
> | lodash | 2 repos | ⚠️ different versions (4.17, 4.21, 5.0) |
> | <abandoned-lib> | 1 repo | 🔴 last commit 2 yr ago — migrate |
>
> 1 risk flagged: <abandoned-lib> is unmaintained; consider replacing.

### Phase R6 — Action plan + report
> Audit report saved: 02_Areas/cross-repo-audit/2026-05-20-audit.md
>
> Suggested action queue (priority order, micronized):
>
> Macro #1: Extract auth-utils package (Σ 8h)
>   ├── Micro #1.1 [parallel] Create `<user>-py-auth-utils` private repo via gh repo create
>   ├── Micro #1.2 [parallel] Define package.json + Python setup.py
>   ├── Micro #1.3 [blocked-by: #1.1] Move auth/jwt.py to new repo + adapt imports
>   ├── Micro #1.4 [blocked-by: #1.3] Publish v0.1.0 to internal package registry
>   ├── Micro #1.5 [blocked-by: #1.4] Open PR to finance-helper removing local copy
>   ├── Micro #1.6 [blocked-by: #1.4] Open PR to fitness-tracker-weekly (parallel with #1.5)
>   └── Micro #1.7 [blocked-by: #1.4] Open PR to clasycare-web (parallel)
>
> ... (3 more macros) ...

### End-of-run summary

```
🔍 Cross-repo audit complete.

Scanned: 12 repos (GitHub: 10, local: 1, vault: 8)

Findings:
  🔗 5 similar repo pairs (score ≥ 50)
  🧬 3 duplication clusters (~620 lines estimated)
  🌐 10 heavily-used external libs (1 flagged risky)

Recommendations:
  📚 2 shared library extractions
  🧩 1 monorepo consolidation candidate
  📌 1 dependency alignment opportunity
  ⚠️ 1 external dep risk (abandoned library)

Report saved: 02_Areas/cross-repo-audit/2026-05-20-audit.md
Tasks created: 4 macros, 18 micros

Suggested next steps:
  1. Review the audit report
  2. Approve specific recommendations
  3. Run /project-init --audit-repos --execute --rec=1 to apply Rec 1 as PRs
```
