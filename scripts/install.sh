#!/usr/bin/env bash
# project-init agent installer for Linux/macOS.
# Copies the agent file into the user's Claude Code agents directory.

set -euo pipefail

AGENT_FILE="agent/project-init.md"
TARGET_DIR="${HOME}/.claude/agents"

if [[ ! -f "${AGENT_FILE}" ]]; then
  echo "Error: ${AGENT_FILE} not found. Run this script from the repo root." >&2
  exit 1
fi

mkdir -p "${TARGET_DIR}"
cp "${AGENT_FILE}" "${TARGET_DIR}/"

echo "Installed project-init agent to ${TARGET_DIR}/project-init.md"
echo ""
echo "Restart Claude Code (close and reopen), then call:"
echo "  /project-init \"your project idea here\""
echo ""
echo "Optional environment variables to configure:"
echo "  export OBSIDIAN_VAULT=\"\$HOME/Documents/MyVault\""
echo "  export PROJECTS_ROOT=\"\$HOME/dev\""
echo "  export PROJECT_INIT_VISIBILITY=\"private\""
