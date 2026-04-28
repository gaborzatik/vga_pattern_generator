[CmdletBinding()]
param(
    [string]$Vivado = $env:VIVADO_BIN,
    [switch]$IncludeAggregate,
    [switch]$ContinueOnError
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if ([string]::IsNullOrWhiteSpace($Vivado)) {
    $Vivado = "vivado"
}

$vivadoCommand = Get-Command $Vivado -ErrorAction SilentlyContinue
if ($null -eq $vivadoCommand) {
    throw "Vivado executable not found. Put vivado on PATH or set VIVADO_BIN to the full executable path."
}

$simScripts = Get-ChildItem -Path (Join-Path $repoRoot "projects") -Recurse -Filter "run_sim_*.tcl" |
    Where-Object { $IncludeAggregate -or $_.Name -ne "run_sim_all.tcl" } |
    Sort-Object FullName

if ($simScripts.Count -eq 0) {
    throw "No simulation scripts found under projects/**/vivado/run_sim_*.tcl."
}

$logRoot = Join-Path $repoRoot "build/ci-logs/sim-logs"
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

$failures = @()

Write-Host "Vivado executable: $($vivadoCommand.Source)"
Write-Host "Simulation scripts:"
foreach ($script in $simScripts) {
    $relativePath = $script.FullName.Substring($repoRoot.Length).TrimStart("\", "/")
    Write-Host "  - $relativePath"
}

foreach ($script in $simScripts) {
    $relativePath = $script.FullName.Substring($repoRoot.Length).TrimStart("\", "/")
    $logName = ($relativePath -replace '[\\/:*?"<>|]', "_") -replace "\.tcl$", ".log"
    $logPath = Join-Path $logRoot $logName

    Write-Host ""
    Write-Host "==> Running $relativePath"
    Write-Host "    Log: $logPath"

    & $vivadoCommand.Source -mode batch -source $script.FullName 2>&1 |
        Tee-Object -FilePath $logPath
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        $failures += [PSCustomObject]@{
            Script = $relativePath
            ExitCode = $exitCode
            Log = $logPath
        }

        Write-Host "::error file=$relativePath::Vivado simulation failed with exit code $exitCode"

        if (-not $ContinueOnError) {
            break
        }
    } else {
        Write-Host "Simulation passed: $relativePath"
    }
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Failed simulations:"
    foreach ($failure in $failures) {
        Write-Host "  - $($failure.Script) (exit $($failure.ExitCode))"
        Write-Host "    $($failure.Log)"
    }

    exit 1
}

Write-Host ""
Write-Host "All simulations passed."
