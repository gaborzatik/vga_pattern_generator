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

- Clocking Wizard instance/module name: `clk_wiz_pixel_25_2MHz`
- Input clock port name: `clk_in1`
- Output clock port name used by the wrapper: `clk_out1`
- Reset port name: `reset`
- Locked port name: `locked`
- Reset is actively used by the wrapper
- Locked is actively used by the wrapper
- Basys3 board input clock is 100 MHz

### Reconstructed assumption

- Requested output frequency: `25.200 MHz`

This assumption comes from the module name plus the default wrapper VGA mode
(`VGA_640X480_60`). If you still have the original Vivado IP customization
files, compare them against the Tcl and update the property set if needed.

## Vivado usage

From the repository root:

```powershell
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/create_project.tcl
```

This recreates the project under:

```text
build/basys3_vga_pattern_generator
```
