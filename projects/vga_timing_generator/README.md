# vga_timing_generator

`vga_timing_generator` is a reusable VHDL subproject that generates VGA-style
horizontal and vertical timing signals for a selected video mode. The current
implementation focuses on timing generation only: it produces sync outputs,
active-area flags, and pixel coordinates for the addressable video region.

## Current scope

The subproject currently contains:

- A timing package with supported VGA modes, timing records, sync polarity
  definitions, and helper functions
- A synthesizable RTL core that drives `hsync`, `vsync`, active video flags,
  and pixel coordinates
- A minimal Vivado recreate script for rebuilding the project from versioned
  sources

The following directories already exist in the structure but are placeholders
at the moment:

- `constrs/`
- `sim/`

That means there is currently no committed XDC constraints file and no
simulation testbench in this subproject yet.

## Source files

- `pkg/vga_timing_pkg.vhd`
  Defines:
  - `t_sync_polarity`
  - `t_vga_mode`
  - `t_vga_timing`
  - helper functions for totals, active ranges, addressable ranges, and
    coordinate bus widths
- `rtl/core/vga_timing_generator.vhd`
  Implements the actual timing generator core
- `vivado/create_project.tcl`
  Recreates a minimal Vivado project and sets `vga_timing_generator` as the top
  module

## Supported modes

The package currently defines the following modes:

| Mode | Addressable resolution | Pixel clock | HSync polarity | VSync polarity | Total frame size |
| --- | --- | --- | --- | --- | --- |
| `VGA_640X480_60` | 640 x 480 | 25.175 MHz | active low | active low | 800 x 525 |
| `SVGA_800X600_60` | 800 x 600 | 40.000 MHz | active high | active high | 1056 x 628 |
| `XGA_1024X768_60` | 1024 x 768 | 65.000 MHz | active low | active low | 1344 x 806 |

The module does not generate the pixel clock internally. It expects
`pixel_clk_i` to already run at the correct frequency for the selected
`G_VGA_MODE`.

## RTL interface

Entity: `vga_timing_generator`

Generic:

- `G_VGA_MODE`
  Selects the timing preset from `t_vga_mode`

Inputs:

- `pixel_clk_i`
  Pixel clock for the selected mode
- `sync_pos_rst_i`
  Synchronous active-high reset for the timing counters

Outputs:

- `hsync_o`
  Horizontal sync output with polarity derived from the selected mode
- `vsync_o`
  Vertical sync output with polarity derived from the selected mode
- `active_video_o`
  High during the complete active display interval, including borders and the
  addressable image area
- `video_on_o`
  High only during the addressable image area
- `x_o`
  Zero-based X coordinate inside the addressable region
- `y_o`
  Zero-based Y coordinate inside the addressable region

When `video_on_o = '0'`, both coordinate outputs are driven to zero.

## Design behavior

The RTL core uses horizontal and vertical counters derived from the selected
timing record.

- Horizontal counting advances every `pixel_clk_i` cycle
- Vertical counting advances when the horizontal counter wraps
- Sync outputs are generated from the counter windows and the configured sync
  polarity
- `active_video_o` and `video_on_o` are derived from separate active and
  addressable regions
- Static assertions check timing consistency during elaboration

This makes the module suitable as a timing backbone for later pattern
generation or framebuffer-based VGA output.

## Repository layout

- `pkg/`
  Shared timing definitions and helper functions
- `rtl/core/`
  Synthesizable timing generator RTL
- `vivado/`
  Project recreation scripts
- `constrs/`
  Reserved for board or design constraints
- `sim/`
  Reserved for simulation sources and testbenches

## Recreating the Vivado project

From the repository root:

```tcl
vivado -mode batch -source projects/vga_timing_generator/vivado/create_project.tcl
```

The script currently:

- creates the project under `build/vga_timing_generator`
- targets FPGA part `xc7a35tcpg236-1`
- adds the package and RTL source files
- sets `vga_timing_generator` as the top module