# GitHub Actions Vivado runner setup

The simulation entry-point validation workflow runs automatically for pull
requests and pushes to `main` through `.github/workflows/vivado-sim.yml`.

The repository has two GitHub Actions workflows:

- `Simulation Entry Points`: runs on GitHub-hosted runners and validates the
  committed `run_sim_*.tcl` entry points.
- `Vivado XSim Regression`: manually runs Vivado/XSim on a self-hosted runner.

Vivado is not installed on standard GitHub-hosted runners, so the workflow uses
a self-hosted runner with these labels:

- `self-hosted`
- `vivado`

## Runner requirements

- Vivado installed on the runner machine
- PowerShell available as `pwsh`
- GitHub Actions runner configured for this repository or organization
- Runner labels include `vivado`
- Either `vivado` is available on `PATH`, or the repository variable
  `VIVADO_BIN` points to the executable

Example `VIVADO_BIN` values:

```text
C:\Xilinx\Vivado\2023.2\bin\vivado.bat
/tools/Xilinx/Vivado/2023.2/bin/vivado
```

Set `VIVADO_BIN` in GitHub:

```text
Settings -> Secrets and variables -> Actions -> Variables -> New repository variable
```

## Automatic PR validation

After the workflow file is present on the branch, every pull request update
starts the `Simulation Entry Points / Repository validation` check. This check
does not require Vivado and should run on GitHub-hosted infrastructure.

## Manual Vivado regression

Start the `Vivado XSim Regression` workflow manually from the GitHub Actions
tab when the self-hosted Vivado runner is online. The job runs:

```powershell
./scripts/run_all_simulations.ps1 -ContinueOnError
```

`-ContinueOnError` keeps the regression running after a failure, then reports
all failed simulation scripts at the end.

## Manual run options

Manual inputs:

- `include_aggregate`: also run `run_sim_all.tcl` aggregate wrappers
- `stop_on_first_failure`: stop immediately after the first failing simulation

Simulation logs are uploaded as the `vivado-simulation-logs` artifact when the
Vivado/XSim job runs.
