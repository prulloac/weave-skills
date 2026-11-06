#requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$Project,
    [string]$Target
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $Target) {
    if ($Project) {
        $Target = Join-Path (Get-Location) ".opencode\skills"
    } else {
        $Target = Join-Path $HOME ".config\opencode\skills"
    }
}

New-Item -ItemType Directory -Force -Path $Target | Out-Null
Copy-Item -Path (Join-Path $Root "skills\weave-cli") -Destination $Target -Recurse -Force
Write-Host "Installed weave-cli to $(Join-Path $Target 'weave-cli')"
Write-Host "Reload OpenCode or run /reload if the skill does not appear."
