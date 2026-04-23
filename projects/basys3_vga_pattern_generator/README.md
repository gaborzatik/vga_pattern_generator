# basys3_vga_pattern_generator

This project is the Basys3-specific wrapper around the shared VGA timing and
pattern-generation cores stored elsewhere in the repository.

## Intent

- keep reusable cores in their own source-controlled subprojects
- keep the Basys3 wrapper limited to board-facing HDL, constraints, and Vivado
  recreation Tcl
- rebuild the Vivado project under `build/` instead of versioning generated
  project artifacts

## What belongs in this wrapper project

- `rtl/basys3_vga_top.vhd`
- `constraints/basys3_vga.xdc`
- `vivado/create_project.tcl`
- optional wrapper-local simulation files under `sim/`

## What stays outside this wrapper project

The shared source files from:

- `projects/vga_timing_generator`
- `projects/vga_pattern_core`

The wrapper Tcl script imports those files from their repository locations. Do
not duplicate them under this project tree.

## Clocking Wizard provenance

The original Clocking Wizard customization file (`.xci`, `.xcix`, or IP Tcl
export) is not present in the current workspace, so the recreation script uses
the strongest facts available from the checked-in sources.

### Directly identified from project files

- Clocking Wizard instance/module name: `clk_wiz_pixel`
- Input clock port name: `clk_in1`
- Output clock port name used by the wrapper: `clk_out1`
- Reset port name: `reset`
- Locked port name: `locked`
- Reset is actively used by the wrapper
- Locked is actively used by the wrapper
- Basys3 board input clock is 100 MHz

### Current reconstructed configuration

- Requested output frequency: `65.000 MHz`
- Current default wrapper mode: `XGA_1024X768_60`

This configuration matches the current wrapper default mode
(`XGA_1024X768_60`) and the checked-in Vivado recreate Tcl. If you still have
the original Vivado IP customization files, compare them against the Tcl and
update the property set if needed.

## RTL linter waiver rationale

Vivado generates a Verilog wrapper for the Clocking Wizard IP under the build
tree. That generated wrapper includes optional clock outputs and internal
`*_unused` sink signals even when this project only uses `clk_out1`, `reset`,
and `locked`.

When the RTL linter analyzes that generated wrapper, it reports expected
`ASSIGN-5` and `ASSIGN-6` warnings about bits that are not set or not read.
These warnings originate from tool-generated IP scaffolding rather than from
the checked-in user RTL.

The project therefore keeps targeted linter waivers in a separate
version-controlled Tcl file for the generated Clocking Wizard wrapper
hierarchy (`clk_wiz_pixel_clk_wiz`) instead of modifying the generated IP
sources. This choice keeps the flow reproducible across IP regeneration,
avoids manual edits that Vivado would overwrite, and preserves linter
visibility for the project's own HDL files.

Vivado 2024.2 also requires each `create_waiver` call to include a
`-description` field. The checked-in waiver script supplies that explicitly.

The waivers are loaded by the dedicated linter batch flow rather than being
created during project recreation. In practice, this makes the behavior stable
across separate Vivado batch sessions, because `run_linter.tcl` explicitly
sources the waiver file before calling `synth_design -lint`.

## Vivado usage

From the repository root:

```powershell
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/create_project.tcl
```

This recreates the project under:

```text
build/basys3_vga_pattern_generator
```
