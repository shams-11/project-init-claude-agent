# Contributing

Thanks for your interest in improving `project-init`!

## Reporting bugs / requesting features

Open an issue with:
- What you tried (the prompt you gave the agent)
- What you expected
- What actually happened (paste the per-phase status output)
- Your environment (OS, Claude Code version, whether vault was available)

## Submitting changes

1. Fork the repo
2. Create a feature branch (`feat/your-change`)
3. Edit `agent/project-init.md` for behavior changes, or `docs/` for documentation
4. Test by copying your modified agent to `~/.claude/agents/` and running it
5. Open a pull request describing the change + rationale

## Design principles to preserve

When changing the agent, please preserve these invariants:

- **Orchestrator, not coder** — the agent does NOT write production code; it produces plans and routes work to sub-agents.
- **Operator approval gates** — never make repo/library mutations without explicit user confirmation.
- **Delegate, don't duplicate** — delegate planning/architecture/security/build-resolution to existing sub-agents; do not reinvent their logic.
- **Bilingual** — user-facing in detected language, ADR titles and code in English.
- **Self-healing** — every phase must end with validation; failures route to resolvers (max 3 retries).
- **Idempotent** — re-running on an existing project should produce a diff, not duplicate output.

## Areas where help is wanted

- More language-specific resolver mappings (e.g., Elixir, Scala, Swift)
- Alternative vault conventions (Zettelkasten, Johnny.Decimal)
- More project category heuristics (Phase 1 taxonomy)
- Example outputs for an `examples/` directory
- Translations of the README into more languages

## Code of conduct

Be kind, be specific, attack ideas not people.
