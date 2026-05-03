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
- wrapper-local simulation files under `sim/`

## What stays outside this wrapper project

The shared source files from:

- `projects/vga_timing_generator`
- `projects/vga_pattern_core`

The wrapper Tcl script imports those files from their repository locations. Do
not duplicate them under this project tree.

The current wrapper source import list includes the shared pattern generator
and its committed pattern modules, including `pattern_1pixel_border.vhd`.

## Branch feature summary

This branch refactors the Basys3 wrapper from switch-driven pattern selection
to UART-driven control. The major additions are:

- a synthesizable 9600 baud UART RX block using 8 data bits, no parity, and
  one stop bit
- a UART command decoder with 2-bit operation IDs and 6-bit enum payloads
- a Python host-side CLI in `scripts/vga_uart_cli.py`
- wrapper-level replacement of the raw switch selector path with UART pattern
  commands
- a one-entry pending register so pattern commands are held until the CDC path
  can accept them
- a request/acknowledge multi-bit CDC handshake for sys-clock to pixel-clock
  pattern selector updates
- a reset controller that synchronizes the push-button input in the 100 MHz
  system-clock domain and releases the pixel reset synchronously to the pixel
  clock
- explicit top-level buffering of the 100 MHz Basys3 board clock with `IBUF`
  and `BUFG`
- Clocking Wizard recreation with `No_buffer` input so the shared buffered
  system clock can legally feed both system logic and the pixel clock generator
- board-clock and CDC constraints for timing and report-CDC signoff
- wrapper simulations for UART decoding, CDC payload transfer, and top-level
  UART-driven RGB behavior
- Vivado batch flows for linter, CDC report, synthesis, implementation, and
  bitstream generation

## UART control

Pattern selection is driven by the Basys3 USB-UART receive pin instead of the
board switches. The serial format is 9600 baud, 8 data bits, no parity, and
one stop bit.

Each command is one byte:

```text
bit 7..6  operation id
bit 5..0  enum payload
```

Supported operation IDs:

| Operation ID | Command | Payload |
| --- | --- | --- |
| `00` | `VGA_MODE_SELECT` | Pattern enum value from `t_pattern_mode` |
| `01` | `VGA_CLOCK_SELECT` | Runtime video mode value |

The `VGA_CLOCK_SELECT` wire-protocol name is retained for compatibility with
existing host tooling. In RTL and documentation it now behaves as runtime video
mode select:

| Payload | Runtime mode | Pixel clock |
| --- | --- | --- |
| `0` | `VGA_640X480_60` | 25.175 MHz |
| `1` | `SVGA_800X600_60` | 40.000 MHz |
| `2` | `XGA_1024X768_60` | 65.000 MHz |

Other payload values are ignored. A same-mode command received while idle is
ignored. Any mode command received while a mode switch is busy is ignored,
including a same-mode command. There is no FIFO for mode commands.

The wrapper distinguishes:

- `requested_mode`
  System-domain payload latched before the request toggle and held stable until
  the switch transaction completes
- `current_mode`
  System-domain mode that drives the dedicated clock mux select outputs
- `active_mode`
  Pixel-pipeline mode consumed by timing and pattern cores; it changes only
  after the pixel pipeline is held blank and the release toggle is observed

UART commands are decoded in the 100 MHz system-clock domain. Pattern selector
updates cross into the pixel-clock domain through a small request/acknowledge
handshake CDC, so the multi-bit selector payload is captured as one coherent
value instead of being sampled bit-by-bit. The source side keeps a pending
selector update until the CDC reports ready, so a selector command is not lost
while a previous transfer is still awaiting acknowledgement.

During a mode switch, pattern selector CDC transfers are not started. The
system domain keeps one pending pattern selector slot; pattern commands received
while busy overwrite that slot, so the behavior is last-wins. When the mode
switch completes, the pending selector is transferred if the pending flag is
set. There is no pattern FIFO. The active pattern is not reset to BLACK during a
mode switch; BLACK is only the global reset default.

Runtime mode switches are frame-boundary switches. The pixel-side handshake
waits for `mode_switch_safe_o` from the timing core, asserts a pipeline hold
that blanks RGB/video and drives sync idle for the selected mode, then returns a
toggle-based `safe_ack` to the system-domain FSM. The system FSM switches the
clock mux only after that ack, waits `clock_mux_settle_cycles` system-clock
cycles (default 256) and `locked = 1`, then releases the pixel pipeline with a
release toggle. The first non-held pixel cycle is frame origin before counting
continues.

The push-button reset is synchronized in the 100 MHz system-clock domain. The
pixel pipeline receives its own reset that asserts while the system reset is
active or the pixel clock is not locked, then deasserts synchronously to
`pixel_clk_s`.

## Python UART CLI

The host-side control script is:

```text
scripts/vga_uart_cli.py
```

It opens the selected serial port as 9600 baud, 8N1, sends one command byte,
flushes the port, and exits. Run it from the repository root.

### Install Python and pyserial

On Windows, install Python first if `python` or `py` is not available:

```powershell
winget install Python.Python.3.12
```

Close and reopen PowerShell, then check:

```powershell
py --version
```

Install the serial package:

```powershell
py -m pip install pyserial
```

If `py` is not available but `python` is, the same commands can be run with
`python` instead:

```powershell
python -m pip install pyserial
```

### Find the Basys3 COM port

Windows assigns a COM port to the Basys3 USB-UART interface. You can list
serial ports from PowerShell with:

```powershell
[System.IO.Ports.SerialPort]::GetPortNames()
```

Use the returned port name in the CLI commands, for example `COM9`.

If the script reports that a port cannot be found, the selected COM port does
not exist. If it reports access denied, close any other program that may have
the port open, such as Vivado Hardware Manager, PuTTY, Tera Term, or another
serial monitor.

### List supported enum values

```powershell
py scripts\vga_uart_cli.py list
```

The command prints the pattern enum names and the currently known runtime video
mode names. Pattern names can be used directly in `mode` commands.

### Select a pattern

```powershell
py scripts\vga_uart_cli.py mode --port COM9 RED
```

Expected output:

```text
sent VGA_MODE_SELECT value=2 payload=0x02
```

Useful bring-up examples:

```powershell
py scripts\vga_uart_cli.py mode --port COM9 WHITE
py scripts\vga_uart_cli.py mode --port COM9 RED
py scripts\vga_uart_cli.py mode --port COM9 GREEN
py scripts\vga_uart_cli.py mode --port COM9 BLUE
py scripts\vga_uart_cli.py mode --port COM9 COLOR_BARS
py scripts\vga_uart_cli.py mode --port COM9 GRAYSCALE_RAMP
py scripts\vga_uart_cli.py mode --port COM9 CHECKER_8PX
py scripts\vga_uart_cli.py mode --port COM9 BORDER_1PX
```

The enum can also be sent as a number. This sends `RED`, because `RED` is
index 2 in the pattern list:

```powershell
py scripts\vga_uart_cli.py mode --port COM9 2
```

### Send a raw payload byte

The `raw` command is useful for low-level bring-up or for checking the exact
wire payload:

```powershell
py scripts\vga_uart_cli.py raw --port COM9 0x02
```

`0x02` is binary `00_000010`: operation ID `00`, payload `2`, which selects
the `RED` pattern.

### Runtime video mode command

The CLI `clock` command name follows the compatibility wire protocol, but the
payload now selects the live video mode:

```powershell
py scripts\vga_uart_cli.py clock --port COM9 XGA_1024X768_60
```

Supported payload names are `VGA_640X480_60`, `SVGA_800X600_60`, and
`XGA_1024X768_60`. Unsupported numeric payloads are ignored by the RTL.

### Troubleshooting

- `Python not found`
  Install Python, reopen PowerShell, and prefer the `py` launcher on Windows.
- `No module named serial`
  Run `py -m pip install pyserial`.
- `could not open port 'COM5': FileNotFoundError`
  The port does not exist. List ports and use the returned value, for example
  `COM9`.
- `Access denied`
  Another program has the port open. Close serial monitors and Vivado Hardware
  Manager, then retry.
- The command prints `sent ...` but the picture does not change
  Check that the latest bitstream is programmed, the correct COM port is used,
  the board reset button is released, and the monitor is receiving the XGA
  output.

## Simulation assets

The wrapper project includes a smoke test and a simulation-only clocking model:

- `sim/tb/tb_vga_uart_control.vhd`
  Checks the UART command decoder operation IDs and payload extraction
- `sim/tb/tb_cdc_bus_handshake.vhd`
  Checks the sys-clock to pixel-clock style request/acknowledge payload transfer
- `sim/tb/tb_vga_mode_switch_controller.vhd`
  Checks invalid/same-mode ignore behavior, busy command ignore, request to
  safe-ack to release sequencing, mux selects, and active-mode update
- `sim/model/clk_wiz_pixel.vhd`
  Behavioral model for the Clocking Wizard interface used by the wrapper
- `sim/tb/tb_basys3_vga_top_smoke.vhd`
  Checks reset blanking, sync activity after reset release, and UART-driven
  selector propagation through the wrapper-level RGB outputs

The simulation model is intentionally local to `sim/` and is not a replacement
for the Vivado-generated Clocking Wizard IP used by synthesis and
implementation.

## Clocking Wizard provenance

The original Clocking Wizard customization file (`.xci`, `.xcix`, or IP Tcl
export) is not present in the current workspace, so the recreation script uses
the strongest facts available from the checked-in sources.

### Directly identified from project files

- Clocking Wizard instance/module name: `clk_wiz_pixel`
- Input clock port name: `clk_in1`
- Output clock port names used by the wrapper: `clk_out1`, `clk_out2`,
  `clk_out3`
- Reset port name: `reset`
- Locked port name: `locked`
- Reset is actively used by the wrapper
- Locked is actively used by the wrapper
- Basys3 board input clock is 100 MHz

### Current reconstructed configuration

- Requested output frequencies: `25.175 MHz`, `40.000 MHz`, and `65.000 MHz`
- Current default wrapper mode: `XGA_1024X768_60`
- Clocking Wizard output drives: `No_buffer` for `clk_out1`, `clk_out2`, and
  `clk_out3`, so the dedicated mux primitives receive unbuffered MMCM outputs
- Dedicated clock selection topology: `clk_out1` vs `clk_out2` in the lower
  `BUFGMUX_CTRL`, then lower mux output vs `clk_out3` in the upper
  `BUFGMUX_CTRL`

This configuration matches the runtime mode-switch wrapper and the checked-in
Vivado recreate Tcl. The Clocking Wizard output buffering and generated-clock
constraints must be validated with Vivado after IP generation. If Vivado emits
already-buffered outputs or rejects the buffer topology, keep the dedicated
glitchless clock-mux approach but adjust the IP output-buffer settings or mux
placement to a Vivado-legal structure. Vivado's reported actual output
frequencies must also be checked against the requested `25.175`, `40.000`, and
`65.000 MHz` targets; if one Clocking Wizard cannot produce acceptable
frequencies from the 100 MHz input, stop and report that blocker instead of
changing to DRP, multiple MMCMs, or another clocking architecture. Do not
replace this with DRP/MMCM dynamic reconfiguration without a separate design
decision.

## RTL linter waiver rationale

Vivado generates a Verilog wrapper for the Clocking Wizard IP under the build
tree. That generated wrapper includes optional clock outputs and internal
`*_unused` sink signals even when this project only uses `clk_out1`,
`clk_out2`, `clk_out3`, `reset`, and `locked`.

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

The recreated project pulls in the shared timing core, the shared pattern core,
and the Basys3 top-level wrapper. Pattern selection is driven through
`uart_rx_i`, so `BORDER_1PX` is available through the same selector path as the
other implemented patterns.

Run the wrapper smoke simulation from the repository root with:

```powershell
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_sim_smoke.tcl
```

Run all wrapper simulations from the repository root with:

```powershell
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_sim_all.tcl
```

Generate the wrapper CDC report with:

```powershell
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_report_cdc.tcl
```

Run the linter, synthesis, and implementation flows with:

```powershell
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_linter.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_synthesis.tcl
vivado -mode batch -source projects/basys3_vga_pattern_generator/vivado/run_implementation.tcl
```

The generated bitstream is written under:

```text
build/basys3_vga_pattern_generator/basys3_vga_pattern_generator.runs/impl_1/basys3_vga_top.bit
```

## Current validation status

The previous fixed-XGA wrapper was checked with Vivado 2024.2. After the
runtime mode-switch refactor, Vivado must be rerun to validate the
three-output Clocking Wizard, `BUFGMUX_CTRL` topology, generated-clock
constraints, linter, synthesis, implementation, and CDC report.

Previous fixed-XGA status before this clocking refactor:

- linter completed with 0 errors and 0 critical warnings
- the remaining unwaived lint warning is the existing pattern-core
  `pattern_outputs_s` unused-array warning
- CDC report completes with the custom handshake bus reported as a false-path,
  clock-enable-controlled CDC structure
- synthesis completes with 0 errors and 0 critical warnings
- implementation and bitstream generation complete with 0 errors and 0
  critical warnings
- routed timing is met with positive WNS
- DRC reports 0 checks
- power report runs without missing-clock warnings after the board
  `create_clock` constraint
- wrapper smoke, UART control, and CDC handshake simulations pass when run
  sequentially

The VGA output ports do not yet have board-level `set_output_delay`
constraints. That is acceptable for current Basys3 bring-up, but a formal
external-interface timing signoff should add an explicit output timing model.
