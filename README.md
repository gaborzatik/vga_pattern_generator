# VGA Pattern Generator

This repository contains modular VHDL building blocks for a VGA test-pattern
generator workflow. The current structure is organized around reusable
subprojects so that timing generation, pattern generation, constraints, and
tooling can be versioned independently and recreated cleanly in Vivado from
source-controlled files.

## Repository goals

The repository is intentionally structured around a source-only workflow:

- keep HDL, constraints, testbenches, and Tcl scripts under version control
- keep Vivado-generated build artifacts out of git
- make project recreation reproducible from committed sources
- develop new functionality in isolated feature branches

These goals match the rules summarized in `docs/version_control_rules.md` and
the ignore patterns defined in `.gitignore`.

## What is currently in the repository

The repository is centered around subprojects under `projects/`.

| Project | Purpose | Status on this branch |
| --- | --- | --- |
| [`vga_timing_generator`](projects/vga_timing_generator) | Generates VGA timing, sync signals, active-video flags, and pixel coordinates | Source files present |
| [`vga_pattern_core`](projects/vga_pattern_core) | Generates RGB test patterns from `video_on`, `x`, `y`, and a pattern selector | Source files present |
| [`basys3_vga_pattern_generator`](projects/basys3_vga_pattern_generator) | Basys3-specific top-level wrapper that integrates the shared cores, board constraints, and pixel-clock generation | Source files and recreate Tcl present |

## Subproject overview

### `vga_timing_generator`

This subproject provides the timing backbone for a VGA-style video pipeline.
Its current RTL:

- selects a timing preset through `G_VGA_MODE`
- generates `hsync_o` and `vsync_o`
- exposes both `active_video_o` and `video_on_o`
- outputs zero-based pixel coordinates `x_o` and `y_o` inside the addressable
  region

The timing package currently includes:

- `VGA_640X480_60`
- `SVGA_800X600_60`
- `XGA_1024X768_60`

See the project-level README for details:

- [`projects/vga_timing_generator/README.md`](projects/vga_timing_generator/README.md)

### `vga_pattern_core`

This project is intended to sit downstream of the timing generator and convert
pixel position plus a pattern selector into RGB output data. The documented
source set includes:

- solid color patterns
- grayscale levels and a grayscale ramp
- seven-bar color pattern output
- checkerboard patterns with multiple cell sizes

The detailed project documentation is stored here:

- [`projects/vga_pattern_core/README.md`](projects/vga_pattern_core/README.md)

## How the pieces fit together

At a high level, the intended signal flow is:

1. `vga_timing_generator` produces sync signals, active-video qualification,
   and pixel coordinates.
2. `vga_pattern_core` uses `video_on`, `x`, `y`, and a pattern selector to
   generate RGB values.
3. A future top-level integration project can connect these blocks to board
   pins, clock generation, DAC/output logic, and optional user controls.

This separation keeps timing concerns independent from image content
generation, which makes both blocks easier to test and reuse.

The repository now includes that hardware-facing integration layer for the
Digilent Basys3 board:

1. `vga_timing_generator` generates sync timing and pixel coordinates.
2. `vga_pattern_core` converts position plus selector inputs into RGB data.
3. `basys3_vga_pattern_generator` wraps both cores with Basys3 pin
   constraints and a Vivado-created Clocking Wizard IP that derives the pixel
   clock from the 100 MHz board oscillator.

## Repository layout

- `projects/`
  Reusable subprojects with their own RTL, packages, Vivado scripts, and
  project-specific README files
- `docs/`
  Repository-level process and version-control documentation
- `scripts/`
  Helper scripts reserved for repository automation
- `build/`
  Generated Vivado project output location recreated from Tcl scripts and
  intentionally excluded from version control

## Vivado workflow

The repository favors rebuilding projects from Tcl instead of committing
generated Vivado project directories.

Currently available recreate scripts:

- `projects/vga_timing_generator/vivado/create_project.tcl`
- `projects/vga_pattern_core/vivado/create_project.tcl`
- `projects/basys3_vga_pattern_generator/vivado/create_project.tcl`

Typical usage from the repository root:

```tcl
vivado -mode batch -source projects/vga_timing_generator/vivado/create_project.tcl
```

The recreate scripts are designed to:

- use the repository as the source of truth
- generate Vivado projects under `build/`
- reduce noise in version control
- make the checked-in source set easier to audit and review

For the Basys3 wrapper specifically, the recreate script also:

- imports shared HDL directly from `projects/vga_timing_generator` and
  `projects/vga_pattern_core`
- adds the Basys3 wrapper top-level and XDC files
- recreates the `clk_wiz_pixel` Clocking Wizard IP inside the generated
  Vivado project instead of versioning generated IP output

## Recommended CLI-first workflow

The next step for this repository should be a simulation-first workflow that
stays fully usable from VS Code and batch-mode Vivado Tcl.

Suggested day-to-day flow:

1. Edit VHDL in VS Code only.
2. Run a focused simulation Tcl script for the module you changed.
3. Run the linter Tcl script once the local behavior is correct.
4. Run synthesis for integration-level changes.
5. Run implementation and bitstream generation only when a hardware candidate
   is needed.
6. Program the Basys3 board only after the implementation reports are clean
   enough to trust.

This keeps the fast inner loop centered on simulation instead of on full
project builds.

## Recommended simulation layout

Each reusable project should keep its own simulation assets close to its RTL.
That makes testbenches easier to review, version, and evolve together with the
design they validate.

Recommended structure:

- `projects/vga_timing_generator/sim/tb/`
  Version-controlled VHDL testbenches for timing behavior
- `projects/vga_timing_generator/sim/pkg/`
  Optional simulation-only helper packages, scoreboards, and shared procedures
- `projects/vga_timing_generator/sim/wcfg/`
  Optional checked-in waveform layouts only if they are stable and useful
- `projects/vga_pattern_core/sim/tb/`
  Testbenches for selector decoding and pattern correctness
- `projects/vga_pattern_core/sim/pkg/`
  Shared simulation helpers for pixel and color checks
- `projects/basys3_vga_pattern_generator/sim/tb/`
  Wrapper-level smoke tests and integration checks

Recommended rule:

- prefer several small, purpose-driven testbenches over one monolithic
  all-in-one simulation

For example, it is better to have separate timing, selector, and pattern
behavior testbenches than one large testbench that is difficult to debug after
a regression.

## Recommended first simulation files

The current source set suggests the following first wave of testbenches.

### `vga_timing_generator`

- `tb_vga_timing_generator_reset.vhd`
  Verifies counter reset behavior and the first valid output cycles after reset
- `tb_vga_timing_generator_modes.vhd`
  Verifies frame totals, sync pulse widths, and sync polarities for the
  currently supported modes
- `tb_vga_timing_generator_coordinates.vhd`
  Verifies that `x_o` and `y_o` increment correctly inside the active region
  and return to zero outside `video_on_o`

### `vga_pattern_core`

- `tb_vga_pattern_generator_solid_colors.vhd`
  Verifies that solid-color modes drive the expected RGB values only when
  `video_on_i = '1'`
- `tb_vga_pattern_generator_selectors.vhd`
  Verifies selector decoding, implemented-mode mapping, and black fallback for
  unimplemented pattern values
- `tb_vga_pattern_generator_geometry.vhd`
  Verifies border, checkerboard, color-bar, and grayscale-ramp output at a
  curated set of pixel coordinates

### `basys3_vga_pattern_generator`

- `tb_basys3_vga_top_smoke.vhd`
  Verifies reset release, basic sync activity, and that selector input changes
  propagate through the wrapper-level RGB outputs

These should be treated as regression assets, not one-time bring-up code.

## Recommended Tcl simulation entry points

The repository already uses `vivado/*.tcl` as the entry point for recreate,
lint, synthesis, implementation, and programming flows. Simulation should use
the same pattern.

Suggested script names:

- `projects/vga_timing_generator/vivado/run_sim_reset.tcl`
- `projects/vga_timing_generator/vivado/run_sim_modes.tcl`
- `projects/vga_pattern_core/vivado/run_sim_selectors.tcl`
- `projects/vga_pattern_core/vivado/run_sim_geometry.tcl`
- `projects/basys3_vga_pattern_generator/vivado/run_sim_smoke.tcl`
- `projects/basys3_vga_pattern_generator/vivado/run_sim_all.tcl`

Each simulation Tcl script should ideally:

- recreate or open the project under `build/`
- add the relevant testbench files into `sim_1`
- set the simulation top explicitly
- refresh compile order before launching simulation
- run the simulation in batch mode until the testbench ends with `assert`
  success or failure
- exit with a failing Vivado process status when the testbench reports an
  error
- keep generated waveform databases and logs under ignored build locations

Typical future usage from the repository root:

```powershell
vivado -mode batch -source projects/vga_timing_generator/vivado/run_sim_reset.tcl
vivado -mode batch -source projects/vga_pattern_core/vivado/run_sim_geometry.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_sim_smoke.tcl
```

## Version control policy

In practice, this repository follows a few simple rules:

- HDL sources, Tcl scripts, constraints, and testbenches belong in git
- Vivado-generated directories and logs do not
- `main` should remain stable
- feature work should happen on dedicated branches
- commits should stay focused and traceable
- a behavior change in RTL should usually be paired with a simulation update or
  a documented reason why no simulation changed

## Current next steps suggested by the repository state

Based on the files currently present, the next likely milestones are:

- add the first committed testbenches under the `sim/` directories
- add dedicated `run_sim_*.tcl` scripts beside the existing recreate and build
  scripts
- make simulation the default pre-commit validation step for RTL changes
- validate the Basys3 wrapper flow through synthesis / implementation on
  hardware-ready builds
- extend the repository with additional board wrappers or more reusable display
  pipeline blocks
