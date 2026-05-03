--==============================================================================
-- File        : vga_pattern_generator.vhd
-- Project     : vga_pattern_core
-- Unit        : vga_pattern_generator
--
-- Description :
--   Selects one RGB pattern from the available pattern generators and exposes
--   the selected color on separate VGA red, green, and blue channel outputs.
--
-- Project role:
--   This is the core pattern-selection RTL used between VGA timing generation
--   and board-level RGB output wiring.
--
-- Design level:
--   RTL core.
--
-- Clock/reset:
--   No clock or reset ports; the current implementation is purely combinational
--   and relies on upstream timing to provide stable pixel coordinates and
--   video_on_i.
--
-- Synthesis:
--   Synthesizable combinational RTL.
--
-- Review notes:
--   active_video_o is not present here; video_on_i is treated as the addressable
--   pattern-generation area qualifier. Enum modes without explicit producers are
--   intentionally mapped by the others choice to black in this implementation.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_pattern_common_pkg.all;
use work.vga_timing_pkg.all;

--==============================================================================
-- Entity: vga_pattern_generator
--
-- Purpose:
--   Converts a pattern selector and current addressable pixel coordinate into
--   one RGB sample.
--
-- Interface groups:
--   pattern_sel_i selects a t_pattern_mode encoding; video_on_i qualifies the
--   addressable pattern region; x_i/y_i are pixel coordinates within the timing
--   mode; red_o/green_o/blue_o are the selected 4-bit VGA color channels.
--
-- Clock/reset assumptions:
--   Combinational unit with no internal state. The caller is responsible for any
--   pixel-clock registering, reset behavior, and alignment to sync signals.
--
-- Output semantics:
--   Implemented patterns can blank or color based on video_on_i. Unimplemented
--   selector modes return C_RGB_BLACK through the pattern output array default.
--==============================================================================
entity vga_pattern_generator is
    port (
        -- Encoded pattern selector. Invalid encodings are handled by
        -- pattern_mode_from_select in the common package.
        pattern_sel_i : in  t_pattern_sel_slv;
        -- Runtime video mode shared with the timing generator. The wrapper
        -- changes this only while the pixel pipeline is held blank.
        mode_i        : in  t_vga_mode;
        -- High only for the addressable pattern-generation area, not the broader
        -- visible-video-with-border concept sometimes named active_video_o.
        video_on_i    : in  std_logic;
        -- Pixel coordinates sampled by coordinate-dependent patterns. Solid
        -- patterns intentionally do not consume these coordinates.
        x_i           : in  unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
        y_i           : in  unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0);

        -- Selected RGB channel outputs for the current combinational sample.
        red_o         : out t_rgb_channel;
        green_o       : out t_rgb_channel;
        blue_o        : out t_rgb_channel
    );
end entity vga_pattern_generator;

architecture rtl of vga_pattern_generator is

    -- Decoded selector used to index the pattern-output array.
    signal pattern_mode_s          : t_pattern_mode;

    -- Per-pattern RGB buses. Coordinate-independent patterns share the same
    -- common output type as coordinate-dependent patterns for uniform muxing.
    signal solid_black_rgb_s        : t_rgb_color;
    signal solid_white_rgb_s        : t_rgb_color;
    signal solid_red_rgb_s          : t_rgb_color;
    signal solid_green_rgb_s        : t_rgb_color;
    signal solid_blue_rgb_s         : t_rgb_color;
    signal solid_gray_10_rgb_s      : t_rgb_color;
    signal solid_gray_50_rgb_s      : t_rgb_color;
    signal solid_gray_80_rgb_s      : t_rgb_color;
    signal color_bars_rgb_s         : t_rgb_color;
    signal grayscale_ramp_rgb_s     : t_rgb_color;
    signal checker_1px_rgb_s        : t_rgb_color;
    signal checker_2px_rgb_s        : t_rgb_color;
    signal checker_4px_rgb_s        : t_rgb_color;
    signal checker_8px_rgb_s        : t_rgb_color;
    signal border_1px_rgb_s         : t_rgb_color;

    -- Complete enum-indexed mux table. Unimplemented enum literals are assigned
    -- by the aggregate's others branch below.
    signal pattern_outputs_s       : t_pattern_rgb_array;
    signal selected_rgb_s          : t_rgb_color;

begin

    pattern_mode_s <= pattern_mode_from_select(pattern_sel_i);

    -- Solid black is not gated by video_on_i in its local module because black is
    -- the same value inside and outside the addressable area.
    u_pattern_solid_black : entity work.pattern_solid_black
        port map (
            rgb_o => solid_black_rgb_s
        );

    -- Solid-color producers share the common pattern output interface; only the
    -- selected producer is ultimately observed through selected_rgb_s.
    u_pattern_solid_white : entity work.pattern_solid_white
        port map (
            video_on_i => video_on_i,
            rgb_o => solid_white_rgb_s
        );

    u_pattern_solid_red : entity work.pattern_solid_red
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_red_rgb_s
        );
        
    u_pattern_solid_green : entity work.pattern_solid_green
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_green_rgb_s
        );
      
    u_pattern_solid_blue : entity work.pattern_solid_blue
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_blue_rgb_s
        );
        
    u_pattern_solid_gray_10 : entity work.pattern_solid_gray_10
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_gray_10_rgb_s
        );
        
    u_pattern_solid_gray_50 : entity work.pattern_solid_gray_50
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_gray_50_rgb_s
        );
        
    u_pattern_solid_gray_80 : entity work.pattern_solid_gray_80
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_gray_80_rgb_s
        );

    -- Seven-bar and grayscale-ramp patterns derive their horizontal partitions
    -- from the runtime video mode.
    u_pattern_seven_bars : entity work.pattern_seven_bars
        port map (
            video_on_i => video_on_i,
            mode_i     => mode_i,
            x_i        => x_i,
            rgb_o      => color_bars_rgb_s
        );

    u_pattern_grayscale_ramp : entity work.pattern_grayscale_ramp
        port map (
            video_on_i => video_on_i,
            mode_i     => mode_i,
            x_i        => x_i,
            rgb_o      => grayscale_ramp_rgb_s
        );
        
    -- Checker instances choose their square size by selecting different x/y
    -- coordinate bits at the integration level.
    u_pattern_checker_1px : entity work.pattern_checker
        port map (
            video_on_i => video_on_i,
            x_bit_i    => x_i(0),
            y_bit_i    => y_i(0),
            rgb_o      => checker_1px_rgb_s
        );
        
    u_pattern_checker_2px : entity work.pattern_checker
        port map (
            video_on_i => video_on_i,
            x_bit_i    => x_i(1),
            y_bit_i    => y_i(1),
            rgb_o      => checker_2px_rgb_s
        );
        
    u_pattern_checker_4px : entity work.pattern_checker
        port map (
            video_on_i => video_on_i,
            x_bit_i    => x_i(2),
            y_bit_i    => y_i(2),
            rgb_o      => checker_4px_rgb_s
        );
        
    u_pattern_checker_8px : entity work.pattern_checker
        port map (
            video_on_i => video_on_i,
            x_bit_i    => x_i(3),
            y_bit_i    => y_i(3),
            rgb_o      => checker_8px_rgb_s
        );

    -- Border pattern uses both coordinates and the selected timing mode's
    -- addressable width/height to identify edge pixels.
    u_pattern_1pixel_border : entity work.pattern_1pixel_border
        port map (
            video_on_i => video_on_i,
            mode_i     => mode_i,
            x_i        => x_i,
            y_i        => y_i,
            rgb_o      => border_1px_rgb_s
        );

    -- Maps implemented pattern generators into the full enum space. Reviewers
    -- should treat the default black branch as the current behavior for planned
    -- but not yet implemented pattern modes.
    pattern_outputs_s <= (
        BLACK               => solid_black_rgb_s,
        WHITE               => solid_white_rgb_s,
        RED                 => solid_red_rgb_s,
        GREEN               => solid_green_rgb_s,
        BLUE                => solid_blue_rgb_s,
        GRAY_10             => solid_gray_10_rgb_s,
        GRAY_50             => solid_gray_50_rgb_s,
        GRAY_80             => solid_gray_80_rgb_s,
        COLOR_BARS          => color_bars_rgb_s,
        GRAYSCALE_RAMP      => grayscale_ramp_rgb_s,
        CHECKER_1PX         => checker_1px_rgb_s,
        CHECKER_2PX         => checker_2px_rgb_s,
        CHECKER_4PX         => checker_4px_rgb_s,
        CHECKER_8PX         => checker_8px_rgb_s,
        BORDER_1PX          => border_1px_rgb_s,
        others      => C_RGB_BLACK
    );

    selected_rgb_s <= pattern_outputs_s(pattern_mode_s);

    red_o   <= selected_rgb_s.red;
    green_o <= selected_rgb_s.green;
    blue_o  <= selected_rgb_s.blue;

end architecture rtl;
