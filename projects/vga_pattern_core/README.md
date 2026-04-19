# vga_pattern_core

`vga_pattern_core` is a reusable VHDL subproject that generates RGB test
patterns from pixel coordinates, an active-video qualifier, and a pattern
selector. This README documents the curated source set used on branches where
`vga_pattern_core` is imported into the repository.

## Current scope

The current design contains:

- a common package with RGB types, pattern enumerations, selector utilities,
  and color helper functions
- a grayscale package with predefined 4-bit gray constants
- a top-level pattern generator core that instantiates multiple individual
  pattern modules in parallel
- a set of implemented solid, bar, grayscale, and checkerboard patterns
- a Vivado recreate script for rebuilding the project from the committed source
  set

The following directories exist as placeholders but do not currently contain
committed design content:

- `constrs/`
- `sim/`

That means the imported source set currently focuses on synthesizable design
sources and project recreation, without committed constraints or testbenches.

## Source files

- `pkg/vga_pattern_common_pkg.vhd` defines RGB channel types, the full pattern
  mode enumeration, selector conversions, utility functions, and shared color
  constants
- `pkg/vga_pattern_gray_pkg.vhd` defines fixed grayscale constants from
  `0/15` through `15/15`
- `rtl/core/vga_pattern_generator.vhd` is the top-level pattern core that
  instantiates and multiplexes the individual pattern generators
- `rtl/pattern/pattern_solid_black.vhd` outputs black
- `rtl/pattern/pattern_solid_white.vhd` outputs white during active video
- `rtl/pattern/pattern_solid_red.vhd` outputs red during active video
- `rtl/pattern/pattern_solid_green.vhd` outputs green during active video
- `rtl/pattern/pattern_solid_blue.vhd` outputs blue during active video
- `rtl/pattern/pattern_solid_gray_10.vhd` outputs a low gray level during
  active video
- `rtl/pattern/pattern_solid_gray_50.vhd` outputs a mid gray level during
  active video
- `rtl/pattern/pattern_solid_gray_80.vhd` outputs a high gray level during
  active video
- `rtl/pattern/pattern_seven_bars.vhd` outputs a seven-bar color pattern
- `rtl/pattern/pattern_grayscale_ramp.vhd` outputs a stepped grayscale ramp
- `rtl/pattern/pattern_checker.vhd` outputs checkerboard patterns selected by
  checker cell size
- `vivado/create_project.tcl` recreates the minimal Vivado project and sets
  `vga_pattern_generator` as top

## Implemented patterns

The imported RTL currently implements the following selectable outputs:

| Pattern mode | Behavior |
| --- | --- |
| `BLACK` | Constant black |
| `WHITE` | White inside active video, black outside |
| `RED` | Red inside active video, black outside |
| `GREEN` | Green inside active video, black outside |
| `BLUE` | Blue inside active video, black outside |
| `GRAY_10` | Low gray level inside active video |
| `GRAY_50` | Medium gray level inside active video |
| `GRAY_80` | Bright gray level inside active video |
| `COLOR_BARS` | Seven vertical color bars |
| `GRAYSCALE_RAMP` | Sixteen-step horizontal grayscale ramp |
| `CHECKER_1PX` | 1x1 checkerboard |
| `CHECKER_2PX` | 2x2 checkerboard |
| `CHECKER_4PX` | 4x4 checkerboard |
| `CHECKER_8PX` | 8x8 checkerboard |

The common package already defines many additional pattern mode names for future
expansion, such as PLUGE, crosshatch, circles, ramps, overlays, and motion
tests. In the current imported RTL, those extra selectors are reserved only.
Unimplemented pattern modes fall back to black in the top-level output mapping.

## Color format

The project uses a simple RGB record type:

- each color channel is 4 bits wide
- the combined output is carried as `red_o`, `green_o`, and `blue_o`
- shared constants such as black, white, red, green, blue, yellow, cyan, and
  magenta are defined in `vga_pattern_common_pkg`

This makes the core suitable for simple DAC-style or resistor-ladder VGA output
paths where a compact channel width is enough.

## Top-level interface

Entity: `vga_pattern_generator`

Generics:

- `G_X_WIDTH`
  Bit width of the horizontal coordinate input
- `G_Y_WIDTH`
  Bit width of the vertical coordinate input
- `G_ACTIVE_WIDTH`
  Intended active horizontal resolution
- `G_ACTIVE_HEIGHT`
  Intended active vertical resolution

Inputs:

- `pattern_sel_i`
  Encoded pattern selector value
- `video_on_i`
  Active-video qualifier from the timing generator
- `x_i`
  Zero-based pixel X coordinate inside the addressable region
- `y_i`
  Zero-based pixel Y coordinate inside the addressable region

Outputs:

- `red_o`
  4-bit red channel
- `green_o`
  4-bit green channel
- `blue_o`
  4-bit blue channel

## Internal architecture

The top-level core works as a pattern multiplexer:

- `pattern_sel_i` is decoded into `t_pattern_mode`
- all currently implemented pattern modules are instantiated in parallel
- each module produces one `t_rgb_color`
- the results are collected into a `t_pattern_rgb_array`
- the selected entry drives the final RGB outputs

This approach keeps the pattern modules simple and independent, while making it
easy to add more patterns later by extending the array mapping.

## Important implementation notes

- Most fixed-color patterns are explicitly gated by `video_on_i`, so they drive
  black outside the addressable image area.
- `pattern_solid_black` outputs black unconditionally.
- `pattern_checker` derives checker size directly from coordinate bits, which
  keeps it compact and synthesizable.
- `pattern_seven_bars` and `pattern_grayscale_ramp` are currently written with
  `640` active pixels in mind, as indicated by both the case ranges and the
  comments in the source.
- The selector bus width is derived automatically from the full
  `t_pattern_mode` enumeration, not only from the subset that is currently
  implemented.

## Integration intent

`vga_pattern_core` is designed to work naturally with `vga_timing_generator`.
In a typical pipeline:

1. `vga_timing_generator` provides `video_on_o`, `x_o`, and `y_o`.
2. Those signals feed `video_on_i`, `x_i`, and `y_i` of
   `vga_pattern_generator`.
3. A board-level top module routes `hsync`, `vsync`, and RGB outputs to the
   FPGA pins.

This keeps timing generation separate from image content generation, which is a
good fit for modular FPGA video designs.

## Repository layout

- `pkg/`
  Shared types, selectors, constants, and grayscale definitions
- `rtl/core/`
  Top-level pattern-generator RTL
- `rtl/pattern/`
  Individual pattern implementations
- `vivado/`
  Project recreation script
- `constrs/`
  Reserved for constraints
- `sim/`
  Reserved for simulation assets

## Recreating the Vivado project

From the repository root on branches where this source set is present:

```tcl
vivado -mode batch -source projects/vga_pattern_core/vivado/create_project.tcl
```

The recreate script currently:

- generates the project under `build/vga_pattern_core`
- targets FPGA part `xc7a35tcpg236-1`
- sets `target_language` to `VHDL`
- sets `simulator_language` to `Mixed`
- adds the package, pattern, and core source files
- sets `vga_pattern_generator` as the top module

## Next likely additions

Based on the current source set, the most natural next steps would be:

- implement more of the reserved pattern modes already listed in
  `t_pattern_mode`
- generalize coordinate-based patterns beyond the current 640-pixel assumptions
- add simulation coverage for selector decoding and pattern correctness
- add constraints and board-level integration around the RGB outputs
