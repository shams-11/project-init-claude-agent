# Examples

Sample input → output walkthroughs for each `project-init` mode.

| Example | Mode | Use case |
|---|---|---|
| [new-project-mobile.md](new-project-mobile.md) | MODE_NEW_PROJECT | Starting a mobile fitness tracker from scratch |
| [new-feature-ocr.md](new-feature-ocr.md) | MODE_NEW_FEATURE | Adding receipt OCR to an existing finance app |
| [audit-repos.md](audit-repos.md) | MODE_CROSS_REPO_AUDIT | Scanning all repos for duplication and organization |
| [health-check.md](health-check.md) | MODE_PROJECT_HEALTH_CHECK | Periodic health audit across all projects |

## Want to contribute an example?

Run `/project-init` for a real project of yours, anonymize the output (replace real names with `<placeholder>`), and submit a PR following the same format as the existing examples. See [CONTRIBUTING.md](../CONTRIBUTING.md).

Each example file should include:
1. Input prompt
2. Phase-by-phase abbreviated agent output
3. Final summary
4. (Optional) lessons learned / gotchas encountered

## Notes

- Examples use **synthetic data** (no real PII, no real GitHub usernames).
- Outputs shown here are illustrative — actual agent output may vary slightly based on the prompt, your prior projects, and search results at run time.
- These examples assume the everything-claude-code (ECC) plugin is installed and the agent's sub-agent dependencies are available.
