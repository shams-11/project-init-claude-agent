# project-init agent installer for Windows (PowerShell).
# Copies the agent file into the user's Claude Code agents directory.

$ErrorActionPreference = "Stop"

$agentFile = "agent\project-init.md"
$targetDir = Join-Path $env:USERPROFILE ".claude\agents"

if (-not (Test-Path $agentFile)) {
    Write-Error "Error: $agentFile not found. Run this script from the repo root."
    exit 1
}

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Copy-Item -Path $agentFile -Destination $targetDir -Force

Write-Host "Installed project-init agent to $targetDir\project-init.md"
Write-Host ""
Write-Host "Restart Claude Code (close and reopen), then call:"
Write-Host "  /project-init `"your project idea here`""
Write-Host ""
Write-Host "Optional environment variables to configure:"
Write-Host "  `$env:OBSIDIAN_VAULT = `"`$env:USERPROFILE\Documents\MyVault`""
Write-Host "  `$env:PROJECTS_ROOT = `"`$env:USERPROFILE\dev`""
Write-Host "  `$env:PROJECT_INIT_VISIBILITY = `"private`""
