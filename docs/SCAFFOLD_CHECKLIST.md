# Scaffold checklist & templates

This document holds the concrete file templates and configurations the agent writes during Phase 8 (Repo + scaffold). Templates are language-/stack-agnostic where possible, language-specific where needed.

## Index

- [.gitignore (per stack)](#gitignore-per-stack)
- [.editorconfig (universal)](#editorconfig-universal)
- [.gitattributes (universal)](#gitattributes-universal)
- [CI workflow per language](#ci-workflow-per-language)
- [Dependabot config](#dependabot-config)
- [CodeQL security workflow](#codeql-security-workflow)
- [Pre-commit hooks per language](#pre-commit-hooks-per-language)
- [Issue templates](#issue-templates)
- [Pull request template](#pull-request-template)
- [CODEOWNERS](#codeowners)
- [Branch protection rules (gh API)](#branch-protection-rules-gh-api)
- [README badges](#readme-badges)
- [LICENSE notices](#license-notices)
- [Multi-environment configs](#multi-environment-configs)
- [CHANGELOG initialization](#changelog-initialization)

---

## .gitignore (per stack)

Fetch language-specific templates from GitHub's collection:
```bash
gh api repos/github/gitignore/contents/<Lang>.gitignore --jq '.content' | base64 -d
```
Common languages: `Python`, `Node`, `Dart`, `Go`, `Rust`, `Java`, `Kotlin`. Concatenate multiple for monorepo (e.g., `Python` + `Dart` for FastAPI + Flutter).

Always append:
```
# OS
.DS_Store
Thumbs.db
desktop.ini

# Editor
.idea/
.vscode/
*.swp

# Secrets (never commit)
.env
.env.local
.env.*.local
*.key
*.pem
secrets/

# Local state
.cache/
*.local.*
```

## .editorconfig (universal)

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
trim_trailing_whitespace = true
insert_final_newline = true

[*.py]
indent_size = 4

[*.go]
indent_style = tab

[Makefile]
indent_style = tab

[*.md]
trim_trailing_whitespace = false
```

## .gitattributes (universal)

```
* text=auto eol=lf
*.bat text eol=crlf
*.png binary
*.jpg binary
*.pdf binary
*.zip binary
```

---

## CI workflow per language

Path: `.github/workflows/ci.yml`

### Python (pytest + ruff + mypy)

```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'
      - run: pip install -r requirements.txt -r requirements-dev.txt
      - run: ruff check .
      - run: mypy .
      - run: pytest --cov --cov-report=xml
      - uses: codecov/codecov-action@v4
        with:
          files: ./coverage.xml
```

### Node / TypeScript

```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm test
      - run: npm run build
```

### Dart / Flutter

```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  analyze-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze
      - run: flutter test --coverage
```

### Go

```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - run: go vet ./...
      - run: go test -race -coverprofile=coverage.out ./...
      - uses: golangci/golangci-lint-action@v6
```

### Rust

```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: rustfmt, clippy
      - run: cargo fmt --check
      - run: cargo clippy -- -D warnings
      - run: cargo test
```

---

## Dependabot config

Path: `.github/dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"

  # Uncomment ecosystems matching the project stack:
  # - package-ecosystem: "npm"
  #   directory: "/"
  #   schedule:
  #     interval: "weekly"
  # - package-ecosystem: "pip"
  #   directory: "/"
  #   schedule:
  #     interval: "weekly"
  # - package-ecosystem: "gomod"
  #   directory: "/"
  #   schedule:
  #     interval: "weekly"
  # - package-ecosystem: "cargo"
  #   directory: "/"
  #   schedule:
  #     interval: "weekly"
  # - package-ecosystem: "docker"
  #   directory: "/"
  #   schedule:
  #     interval: "weekly"
```

---

## CodeQL security workflow

Path: `.github/workflows/codeql.yml`

```yaml
name: CodeQL
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 6 * * 1'

jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
    strategy:
      fail-fast: false
      matrix:
        language: [python]  # or [javascript-typescript, go, java, ruby, csharp, cpp]
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
      - uses: github/codeql-action/autobuild@v3
      - uses: github/codeql-action/analyze@v3
```

CodeQL does not support Dart/Flutter natively. For Dart, use `dart_code_metrics` or `dart_code_linter` in CI workflow instead.

---

## Pre-commit hooks per language

### Python — `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.5.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.10.0
    hooks:
      - id: mypy

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-merge-conflict
```

User installs once: `pip install pre-commit && pre-commit install`.

### Node / TypeScript — Husky + lint-staged

`package.json` additions:
```json
{
  "scripts": {
    "prepare": "husky"
  },
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml,yaml}": ["prettier --write"]
  }
}
```

`.husky/pre-commit`:
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
npx lint-staged
```

`.husky/commit-msg`:
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
npx --no-install commitlint --edit "$1"
```

`commitlint.config.js`:
```js
module.exports = { extends: ['@commitlint/config-conventional'] };
```

### Dart / Flutter — Lefthook

`lefthook.yml`:
```yaml
pre-commit:
  parallel: true
  commands:
    format:
      glob: "*.dart"
      run: dart format --set-exit-if-changed {staged_files}
    analyze:
      run: flutter analyze --no-pub --no-current-package
```

### Go — `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/dnephin/pre-commit-golang
    rev: v0.5.1
    hooks:
      - id: go-fmt
      - id: go-vet
      - id: go-mod-tidy
      - id: golangci-lint
```

### Rust — `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/doublify/pre-commit-rust
    rev: v1.0
    hooks:
      - id: fmt
      - id: clippy
        args: [--, -D, warnings]
```

---

## Issue templates

Path: `.github/ISSUE_TEMPLATE/`

### `bug_report.yml`

```yaml
name: Bug report
description: Report a bug or unexpected behavior
labels: [bug]
body:
  - type: textarea
    id: what-happened
    attributes:
      label: What happened?
      description: A clear description of the bug.
    validations:
      required: true
  - type: textarea
    id: reproduction
    attributes:
      label: Steps to reproduce
      placeholder: |
        1.
        2.
        3.
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected behavior
    validations:
      required: true
  - type: input
    id: version
    attributes:
      label: Version / commit hash
    validations:
      required: true
  - type: textarea
    id: environment
    attributes:
      label: Environment (OS, runtime versions, browser, etc.)
```

### `feature_request.yml`

```yaml
name: Feature request
description: Suggest a new feature or improvement
labels: [enhancement]
body:
  - type: textarea
    id: problem
    attributes:
      label: What problem does this solve?
    validations:
      required: true
  - type: textarea
    id: proposal
    attributes:
      label: Proposed solution
    validations:
      required: true
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives considered
```

### `question.yml`

```yaml
name: Question
description: Ask a question about usage, config, or behavior
labels: [question]
body:
  - type: textarea
    id: question
    attributes:
      label: Your question
    validations:
      required: true
  - type: textarea
    id: tried
    attributes:
      label: What you have tried so far
```

---

## Pull request template

Path: `.github/PULL_REQUEST_TEMPLATE.md`

```markdown
## Summary
<!-- What does this PR do? -->

## Changes
- [ ]

## Why
<!-- Why is this change needed? -->

## Testing
<!-- How did you verify? -->

## Breaking changes
- [ ] No
- [ ] Yes — describe migration

## Screenshots (UI changes only)

## Checklist
- [ ] Tests added/updated
- [ ] Docs updated
- [ ] Conventional commit messages
- [ ] CI passes locally
```

---

## CODEOWNERS

Path: `.github/CODEOWNERS`

Solo project:
```
* @<your-github-username>
```

Team project (example):
```
# Global
* @<owner>

# Backend
/backend/  @<backend-lead> @<backend-team>

# Frontend
/mobile/   @<mobile-lead>
/web/      @<frontend-lead>

# Infrastructure
/.github/  @<devops-lead>
/docker-compose.yml  @<devops-lead>
/Dockerfile          @<devops-lead>

# Security-sensitive
/auth/             @<security-reviewer>
/payments/         @<security-reviewer>
```

---

## Branch protection rules (gh API)

After `git push`, apply main protection if user approves:

```bash
gh api -X PUT "/repos/$(gh api user --jq .login)/<slug>/branches/main/protection" \
  -F "required_status_checks[strict]=true" \
  -F "required_status_checks[contexts][]=ci" \
  -F "enforce_admins=false" \
  -F "required_pull_request_reviews[required_approving_review_count]=1" \
  -F "required_pull_request_reviews[dismiss_stale_reviews]=true" \
  -F "restrictions=null" \
  -F "allow_force_pushes=false" \
  -F "allow_deletions=false"
```

For solo projects, the `required_approving_review_count=0` variant or skip protection entirely.

---

## README badges

Add to top of `README.md`:

```markdown
[![CI](https://github.com/<user>/<slug>/actions/workflows/ci.yml/badge.svg)](https://github.com/<user>/<slug>/actions/workflows/ci.yml)
[![CodeQL](https://github.com/<user>/<slug>/actions/workflows/codeql.yml/badge.svg)](https://github.com/<user>/<slug>/actions/workflows/codeql.yml)
[![License](https://img.shields.io/github/license/<user>/<slug>.svg)](LICENSE)
[![Issues](https://img.shields.io/github/issues/<user>/<slug>.svg)](https://github.com/<user>/<slug>/issues)
```

Optional language version badges:
```markdown
[![Python](https://img.shields.io/badge/python-3.12-blue.svg)](https://www.python.org/)
[![Node](https://img.shields.io/badge/node-20.x-green.svg)](https://nodejs.org/)
[![Flutter](https://img.shields.io/badge/flutter-3.24-blue.svg)](https://flutter.dev/)
```

---

## LICENSE notices

### MIT (`LICENSE`)
Standard MIT template — see SPDX or `gh api licenses/mit`.

### Apache-2.0
`gh api licenses/apache-2.0`. Plus `NOTICE` file template.

### GPL-3.0 / AGPL-3.0
`gh api licenses/gpl-3.0` or `agpl-3.0`. Note: every file must have a header — add to template.

### Private / Proprietary
```
Copyright (c) <year> <owner>. All rights reserved.

This source code is proprietary and confidential.
Unauthorized copying, modification, distribution, or use is strictly prohibited.
```

---

## Multi-environment configs

`.env.example` (commit):
```
DB_URL=postgresql://user:password@localhost:5432/dbname
JWT_SECRET=replace-with-strong-random
REDIS_URL=redis://localhost:6379
LOG_LEVEL=info
ENV=development
```

`.env.staging.example` (commit):
```
DB_URL=postgresql://...staging...
ENV=staging
LOG_LEVEL=info
```

`.env.production.example` (commit, README note: use GitHub Actions Secrets / Vault / SOPS for real values):
```
DB_URL=<set via secret manager>
ENV=production
LOG_LEVEL=warn
```

Add to `.gitignore`:
```
.env
.env.local
.env.staging
.env.production
```

---

## CHANGELOG initialization

Path: `CHANGELOG.md`

Format: [Keep a Changelog](https://keepachangelog.com/) + [Semantic Versioning](https://semver.org/).

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial Phase-0 scaffold (PRD + ADRs + tech stack + components + roadmap)

## [0.1.0] — TBD
- (Sprint 1 first release)
```
