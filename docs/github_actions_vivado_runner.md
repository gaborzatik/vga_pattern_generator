# GitHub Actions Vivado runner setup

The simulation validation workflow runs automatically for pull requests and
pushes to `main` through `.github/workflows/vivado-sim.yml`.

The workflow has two jobs:

- `Repository validation`: runs on GitHub-hosted runners and validates the
  committed `run_sim_*.tcl` entry points.
- `XSim regression`: runs Vivado/XSim on a self-hosted runner only when that
  runner is explicitly enabled.

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

To enable automatic Vivado/XSim runs on pull requests and pushes, also create
this repository variable:

```text
VIVADO_SELF_HOSTED_ENABLED=true
```

Leave this variable unset until the self-hosted runner is online. Otherwise,
GitHub queues the `XSim regression` job while it waits for a matching runner.

## Automatic PR validation

After the workflow file is present on the branch, every pull request update
starts the `Vivado Simulation / Repository validation` check. This check does
not require Vivado and should run on GitHub-hosted infrastructure.

When `VIVADO_SELF_HOSTED_ENABLED=true`, pull request updates also start the
`Vivado Simulation / XSim regression` check. That job runs:

```powershell
./scripts/run_all_simulations.ps1 -ContinueOnError
```

`-ContinueOnError` keeps the regression running after a failure, then reports
all failed simulation scripts at the end.

## Manual run options

The workflow can also be started from the GitHub Actions tab with
`workflow_dispatch`.

Manual inputs:

- `run_vivado`: run the Vivado/XSim regression on the self-hosted runner
- `include_aggregate`: also run `run_sim_all.tcl` aggregate wrappers
- `stop_on_first_failure`: stop immediately after the first failing simulation

Simulation logs are uploaded as the `vivado-simulation-logs` artifact when the
Vivado/XSim job runs.
