# Vivado flow scripts

This directory contains batch-mode Vivado Tcl scripts for the
`basys3_vga_pattern_generator` project.

## Available scripts

- `create_project.tcl`
  Recreates the Vivado project under `build/basys3_vga_pattern_generator`
- `lint_waivers.tcl`
  Defines the RTL linter waivers that suppress expected Clocking Wizard
  wrapper-only lint noise
- `run_linter.tcl`
  Opens or recreates the project, loads `lint_waivers.tcl`, then runs the RTL
  linter on the top-level design
- `run_report_cdc.tcl`
  Opens or recreates the project, synthesizes the top-level design, then emits
  a detailed CDC report under the project reports directory
- `run_sim_smoke.tcl`
  Opens or recreates the project, disables the generated Clocking Wizard IP for
  simulation, adds the simulation-only clock model and wrapper smoke test, then
  runs behavioral XSim
- `run_sim_uart_control.tcl`
  Opens or recreates the project, adds the UART control decoder testbench, then
  runs behavioral XSim
- `run_sim_mode_switch_controller.tcl`
  Opens or recreates the project, adds the runtime mode-switch controller
  testbench, then runs behavioral XSim
- `run_sim_cdc_bus_handshake.tcl`
  Opens or recreates the project, adds the CDC bus handshake testbench, then
  runs behavioral XSim
- `run_sim_all.tcl`
  Runs the current Basys3 wrapper simulation suite
- `run_synthesis.tcl`
  Opens or recreates the project, resets prior synthesis results, runs
  `synth_1`, and writes synthesis reports
- `run_implementation.tcl`
  Opens or recreates the project, reruns synthesis as a prerequisite, runs
  `impl_1` through bitstream generation, and writes implementation reports
- `write_bitstream_only.tcl`
  Opens the existing project, verifies that `impl_1` already completed, then
  writes the bitstream again from the existing implemented design
- `program_basys3.tcl`
  Opens the project, connects to the local Vivado hardware server, opens the
  Basys3 JTAG target, and programs the FPGA with the generated bitstream

## Typical usage

Run the scripts from the repository root:

```powershell
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/create_project.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_linter.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_report_cdc.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_sim_cdc_bus_handshake.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_sim_uart_control.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_sim_mode_switch_controller.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_sim_smoke.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_sim_all.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_synthesis.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_implementation.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/write_bitstream_only.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/program_basys3.tcl
```

If `vivado` is not on `PATH`, launch the same scripts through the full path to
`vivado.bat`.

## What each script produces

### `run_sim_smoke.tcl`

This script produces behavioral simulation output under:

- `build/basys3_vga_pattern_generator/basys3_vga_pattern_generator.sim/sim_1/behav/xsim/`

The smoke test uses:

- `sim/model/clk_wiz_pixel.vhd`
- `sim/tb/tb_basys3_vga_top_smoke.vhd`

It verifies reset blanking, basic sync activity, UART-driven selector
propagation through the wrapper-level RGB outputs, and a UART runtime mode
command that restarts timing with VGA hsync width. The script temporarily marks
the generated Clocking Wizard IP as not used for simulation so the checked-in
simulation model can provide the same entity interface.

### `run_sim_uart_control.tcl`

This script produces behavioral simulation output under:

- `build/basys3_vga_pattern_generator/basys3_vga_pattern_generator.sim/sim_1/behav/xsim/`

The testbench uses:

- `sim/tb/tb_vga_uart_control.vhd`

It verifies the one-byte UART command format, including `VGA_MODE_SELECT`
pattern payload decoding and `VGA_CLOCK_SELECT` runtime video mode payload
capture.

### `run_sim_mode_switch_controller.tcl`

This script produces behavioral simulation output under:

- `build/basys3_vga_pattern_generator/basys3_vga_pattern_generator.sim/sim_1/behav/xsim/`

The testbench uses:

- `sim/tb/tb_vga_mode_switch_controller.vhd`

It verifies invalid payload ignore, idle same-mode ignore, busy command ignore,
request/safe-ack/release sequencing, mux select updates, and active-mode update.

### `run_sim_cdc_bus_handshake.tcl`

This script produces behavioral simulation output under:

- `build/basys3_vga_pattern_generator/basys3_vga_pattern_generator.sim/sim_1/behav/xsim/`

The testbench uses:

- `sim/tb/tb_cdc_bus_handshake.vhd`

It verifies that a multi-bit payload launched in one clock domain is delivered
with a single valid pulse in a second clock domain by the wrapper-local
request/acknowledge CDC module.

### `run_sim_all.tcl`

This script runs `run_sim_cdc_bus_handshake.tcl`, `run_sim_uart_control.tcl`,
`run_sim_mode_switch_controller.tcl`, and `run_sim_smoke.tcl` as the aggregate
Basys3 wrapper simulation entry point.

### `run_linter.tcl`

The linter runs directly in batch mode and reports findings to the Vivado batch
log. It does not create a separate design run like `synth_1` or `impl_1`.
Before running the linter, the script explicitly sources `lint_waivers.tcl`.

### `run_report_cdc.tcl`

This script produces:

- `build/basys3_vga_pattern_generator/reports/cdc_report.rpt`

Use it after CDC-related RTL or constraint changes. The wrapper includes
`constraints/basys3_cdc.xdc` for the custom request/acknowledge selector CDC.
Review the report together with that XDC file before treating an implementation
as CDC-clean.

### `run_synthesis.tcl`

This script produces:

- `build/basys3_vga_pattern_generator/basys3_vga_pattern_generator.runs/synth_1/runme.log`
- `build/basys3_vga_pattern_generator/reports/synth_utilization.rpt`
- `build/basys3_vga_pattern_generator/reports/synth_timing_summary.rpt`

### `run_implementation.tcl`

This script produces:

- `build/basys3_vga_pattern_generator/basys3_vga_pattern_generator.runs/synth_1/runme.log`
- `build/basys3_vga_pattern_generator/basys3_vga_pattern_generator.runs/impl_1/runme.log`
- `build/basys3_vga_pattern_generator/reports/impl_utilization.rpt`
- `build/basys3_vga_pattern_generator/reports/impl_timing_summary.rpt`
- `build/basys3_vga_pattern_generator/reports/impl_drc.rpt`
- `build/basys3_vga_pattern_generator/reports/impl_power.rpt`

The generated bitstream is written by the implementation run under the
project's `.runs/impl_1/` directory.

### `write_bitstream_only.tcl`

This script produces:

- `build/basys3_vga_pattern_generator/basys3_vga_pattern_generator.runs/impl_1/basys3_vga_top.bit`
- `build/basys3_vga_pattern_generator/reports/impl_timing_summary_recheck.rpt`

Use this script when implementation has already completed and you only want to
re-open the routed design and emit the bitstream again without rerunning the
entire implementation flow.

### `program_basys3.tcl`

This script:

- checks that the generated `.bit` file already exists
- opens Vivado Hardware Manager
- connects to `localhost:3121`
- selects a Digilent target when one is present
- opens the target
- selects the first FPGA device in the JTAG chain
- programs the FPGA with the generated bitstream
- prints the final DONE status

Use this script after `run_implementation.tcl` or `write_bitstream_only.tcl`
when the Basys3 board is connected over USB/JTAG and powered on.

## How to read the logs

### Batch log

When Vivado is launched in batch mode, it writes a `vivado.log` file in the
directory from which the command was started. This is the first place to check
for Tcl errors, missing files, licensing issues, or failed tool commands.

Look for these message classes first:

- `ERROR:`
  The script or a tool step failed and the run cannot be trusted
- `CRITICAL WARNING:`
  The flow continued, but the result might be incomplete or incorrect
- `WARNING:`
  The flow completed, but something should be reviewed

### Linter output

The linter reports rule IDs such as `ASSIGN-5` or `ASSIGN-6`. In this project,
the linter flow explicitly loads targeted waivers for expected Clocking Wizard
wrapper-only noise, so new linter messages outside those waived cases are more
likely to indicate real user-RTL issues.

The waiver targets the generated Clocking Wizard hierarchy
`clk_wiz_pixel_clk_wiz`. On Vivado 2024.2 and newer, the waiver creation also
requires a `-description` field in the waiver script.

Interpretation guideline:

- warnings in checked-in RTL files deserve review
- warnings in Vivado-generated IP wrapper files are often tool scaffolding
- a clean run with no unexpected `ERROR:` or unwaived rule IDs is the goal

### Synthesis logs and reports

`synth_1/runme.log` is the detailed synthesis transcript. Use it to diagnose
front-end parsing errors, elaboration failures, inferred hardware warnings, or
run crashes.

The synthesis reports are best read like this:

- `synth_utilization.rpt`
  Check LUT, FF, BRAM, DSP, BUFG, and IO usage against the target device budget
- `synth_timing_summary.rpt`
  Use this as an early timing estimate; negative WNS or TNS here is a warning
  sign, but final timing signoff must be based on implementation

### Implementation logs and reports

`impl_1/runme.log` is the detailed implementation transcript. Use it for
placement, routing, DRC, clocking, and bitstream generation problems.

The implementation reports are the main signoff artifacts:

- `impl_timing_summary.rpt`
  Check WNS and TNS; meeting timing usually means no negative setup slack
- `impl_drc.rpt`
  Review any DRC violations before trusting the bitstream
- `impl_utilization.rpt`
  Confirms post-implementation resource usage
- `impl_power.rpt`
  Gives the post-implementation power estimate

If implementation completes but timing is negative, the bitstream may still be
generated, but the hardware result should not be considered timing-clean.
