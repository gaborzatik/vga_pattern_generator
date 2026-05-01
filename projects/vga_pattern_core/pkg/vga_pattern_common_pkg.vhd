--==============================================================================
-- File        : vga_pattern_common_pkg.vhd
-- Project     : vga_pattern_core
-- Unit        : vga_pattern_common_pkg
--
-- Description :
--   Defines shared RGB, pattern-selection, and geometry helper abstractions used
--   by the VGA pattern generator RTL and its simulation code.
--
-- Project role:
--   This package is the common type and utility layer for pattern blocks, the
--   top-level pattern multiplexer, and testbench expectations.
--
-- Design level:
--   Package.
--
-- Clock/reset:
--   Not applicable; this package contains declarations and pure helper logic.
--
-- Synthesis:
--   Package declarations and synthesizable helper functions where used by RTL.
--
-- Review notes:
--   The pattern enumeration includes implemented and not-yet-routed modes; the
--   top-level generator decides which modes have dedicated RGB producers.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--==============================================================================
-- Package: vga_pattern_common_pkg
--
-- Purpose:
--   Provides project-wide RGB records, pattern-mode selectors, color constants,
--   and coordinate helper functions.
--
-- Intended users:
--   Pattern RTL blocks, the vga_pattern_generator selector, and simulation
--   utilities that need the same selector encoding and color definitions.
--
-- Synthesis relevance:
--   Constants and functions in this package may be elaborated into RTL when used
--   in synthesizable files; assertions inside helper functions are reviewer
--   visible behavior for invalid selector values.
--==============================================================================
package vga_pattern_common_pkg is

    -- =========================================================================
    -- Color types
    -- =========================================================================

    -- Basys 3 VGA uses four bits per DAC color channel in this project.
    constant C_RGB_WIDTH : natural := 4;

    -- Common per-channel and packed RGB record types keep pattern interfaces
    -- consistent across combinational and future clocked pattern sources.
    subtype t_rgb_channel is std_logic_vector(C_RGB_WIDTH - 1 downto 0);

    type t_rgb_color is record
        red   : t_rgb_channel;
        green : t_rgb_channel;
        blue  : t_rgb_channel;
    end record;

    -- =========================================================================
    -- Pattern mode types
    -- =========================================================================

    -- Selector order is hardware-visible through pattern_select_from_mode and
    -- pattern_mode_from_select; append-only changes are easier to review than
    -- reordering existing literals.
    type t_pattern_mode is (
        BLACK,
        WHITE,
        RED,
        GREEN,
        BLUE,
        GRAY_10,
        GRAY_50,
        GRAY_80,
        COLOR_BARS,
        GRAYSCALE_RAMP,
        CHECKER_1PX,
        CHECKER_2PX,
        CHECKER_4PX,
        CHECKER_8PX, 
        BORDER_1PX,       
        PLUGE_BLACK,
        PLUGE_WHITE,
        CENTER_CROSS,
        CORNER_MARKERS,
        CROSSHATCH_COARSE,
        CROSSHATCH_FINE,
        CIRCLE,
        CIRCLE_GRID,
        LINEARITY_V,
        LINEARITY_H,
        STRIPES_V_1PX,
        STRIPES_H_1PX,
        BURST_V,
        BURST_H,
        FOCUS_TEXT,
        DIAGONAL_TEST,
        RGB_REGISTRATION,
        UNIFORM_DARK,
        UNIFORM_MID,
        UNIFORM_LIGHT,
        MOVING_BAR_H,
        MOVING_BAR_V,
        SCROLL_CHECKER,
        X_RAMP,
        Y_RAMP,
        XY_RAMP,
        ACTIVE_VIDEO_DEBUG,
        MODE_OVERLAY,
        FRAME_MARKER
    );

    type t_pattern_rgb_array is array (t_pattern_mode) of t_rgb_color;

    -- Width calculations derive from the full enum, including modes that the
    -- current top-level generator maps to its default color.
    constant C_PATTERN_COUNT : natural := t_pattern_mode'pos(t_pattern_mode'right) + 1;

    -- =========================================================================
    -- Generic utility functions
    -- =========================================================================

    function required_bit_width(
        value_count : natural
    ) return natural;


    -- Checker mode names identify which coordinate bit is sampled by the
    -- top-level generator rather than configuring pattern_checker directly.
    type t_checker_pixel_mode is (
        CHECKER_PIXEL_1,
        CHECKER_PIXEL_2,
        CHECKER_PIXEL_4,
        CHECKER_PIXEL_8
    );

    -- =========================================================================
    -- Selector types
    -- =========================================================================

    -- Selector width follows the enum size and therefore changes if literals are
    -- added to t_pattern_mode.
    constant C_PATTERN_SEL_WIDTH : natural := required_bit_width(C_PATTERN_COUNT);

    subtype t_pattern_sel_slv is std_logic_vector(C_PATTERN_SEL_WIDTH - 1 downto 0);

    -- =========================================================================
    -- Color constants
    -- =========================================================================

    constant C_RGB_BLACK : t_rgb_color := (
        red   => (others => '0'),
        green => (others => '0'),
        blue  => (others => '0')
    );

    constant C_RGB_WHITE : t_rgb_color := (
        red   => (others => '1'),
        green => (others => '1'),
        blue  => (others => '1')
    );

    constant C_RGB_RED : t_rgb_color := (
        red   => (others => '1'),
        green => (others => '0'),
        blue  => (others => '0')
    );

    constant C_RGB_GREEN : t_rgb_color := (
        red   => (others => '0'),
        green => (others => '1'),
        blue  => (others => '0')
    );

    constant C_RGB_BLUE : t_rgb_color := (
        red   => (others => '0'),
        green => (others => '0'),
        blue  => (others => '1')
    );

    constant C_RGB_YELLOW : t_rgb_color := (
        red   => (others => '1'),
        green => (others => '1'),
        blue  => (others => '0')
    );

    constant C_RGB_CYAN : t_rgb_color := (
        red   => (others => '0'),
        green => (others => '1'),
        blue  => (others => '1')
    );

    constant C_RGB_MAGENTA : t_rgb_color := (
        red   => (others => '1'),
        green => (others => '0'),
        blue  => (others => '1')
    );

    -- =========================================================================
    -- Coordinate / geometry helpers
    -- =========================================================================

    -- Cell end arrays describe monotonically increasing coordinate thresholds
    -- for partitioning a visible region into bars or similar cells.
    type t_cell_end_array is array (natural range <>) of natural;

    function pattern_mode_from_select(
        sel : t_pattern_sel_slv
    ) return t_pattern_mode;

    function pattern_select_from_mode(
        mode : t_pattern_mode
    ) return t_pattern_sel_slv;


end package vga_pattern_common_pkg;


package body vga_pattern_common_pkg is

    -- Computes the minimum selector width needed to encode value_count choices.
    -- The value_count <= 1 case still returns one bit so downstream SLV ranges
    -- remain legal.
    function required_bit_width(
        value_count : natural
    ) return natural is
        variable v_bits  : natural := 0;
        variable v_limit : natural := 1;
    begin
        if value_count <= 1 then
            return 1;
        end if;

        while v_limit < value_count loop
            v_bits  := v_bits + 1;
            v_limit := v_limit * 2;
        end loop;

        return v_bits;
    end function;

    -- Decodes the hardware selector vector into the enum. Invalid encodings
    -- intentionally fall back to BLACK after reporting a warning.
    function pattern_mode_from_select(
        sel : t_pattern_sel_slv
    ) return t_pattern_mode is
        variable v_idx : natural;
    begin
        v_idx := to_integer(unsigned(sel));

        if v_idx < C_PATTERN_COUNT then
            return t_pattern_mode'val(v_idx);
        else
            assert false
                report "Invalid pattern selector value"
                severity warning;
            return BLACK;
        end if;
    end function;

    -- Encodes a pattern enum literal into the selector vector width used by the
    -- top-level pattern generator input.
    function pattern_select_from_mode(
        mode : t_pattern_mode
    ) return t_pattern_sel_slv is
    begin
        return std_logic_vector(
            to_unsigned(
                t_pattern_mode'pos(mode),
                C_PATTERN_SEL_WIDTH
            )
        );
    end function;


end package body vga_pattern_common_pkg;
