[CmdletBinding()]
param(
    [switch]$IncludeAggregate
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$projectsRoot = Join-Path $repoRoot "projects"

$simScripts = @(Get-ChildItem -Path $projectsRoot -Recurse -Filter "run_sim_*.tcl" |
    Where-Object { $IncludeAggregate -or $_.Name -ne "run_sim_all.tcl" } |
    Sort-Object FullName)

if ($simScripts.Count -eq 0) {
    throw "No simulation scripts found under projects/**/vivado/run_sim_*.tcl."
}

$failures = @()

foreach ($script in $simScripts) {
    $relativePath = $script.FullName.Substring($repoRoot.Length).TrimStart("\", "/")
    $content = Get-Content -Raw $script.FullName

    if ($script.Directory.Name -ne "vivado") {
        $failures += "${relativePath}: expected script to live in a vivado directory"
    }

    $requiredPatterns = @(
        'set\s+script_dir',
        'set\s+project_root',
        'set\s+repo_root',
        'set\s+helper_script',
        'set\s+sim_top',
        'source\s+\$helper_script',
        'sim_ensure_project',
        'sim_prepare_fileset',
        'sim_run_fileset',
        'close_project'
    )

    foreach ($pattern in $requiredPatterns) {
        if ($content -notmatch $pattern) {
            $failures += "${relativePath}: missing expected Tcl pattern '$pattern'"
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host "Simulation entry-point validation failed:"
    foreach ($failure in $failures) {
        Write-Host "  - $failure"
    }

    exit 1
}

Write-Host "Validated simulation entry points:"
foreach ($script in $simScripts) {
    $relativePath = $script.FullName.Substring($repoRoot.Length).TrimStart("\", "/")
    Write-Host "  - $relativePath"
}
