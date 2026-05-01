--==============================================================================
-- File        : vga_pattern_sim_pkg.vhd
-- Project     : vga_pattern_core
-- Unit        : vga_pattern_sim_pkg
--
-- Description :
--   Provides simulation-only helper routines for formatting and checking RGB
--   channel values in VGA pattern generator testbenches.
--
-- Project role:
--   Shared assertion utility layer for vga_pattern_core simulation testbenches.
--
-- Design level:
--   Testbench package.
--
-- Clock/reset:
--   Not applicable.
--
-- Synthesis:
--   Simulation-only package.
--
-- Review notes:
--   These helpers do not drive RTL behavior; they only report test failures with
--   consistent expected/actual RGB formatting.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_pattern_common_pkg.all;

--==============================================================================
-- Package: vga_pattern_sim_pkg
--
-- Purpose:
--   Centralizes RGB comparison and reporting utilities used by the testbenches.
--
-- Intended users:
--   Simulation code only. RTL files should depend on vga_pattern_common_pkg
--   instead of this package.
--
-- Verification role:
--   Assertion failures identify mismatched red, green, or blue channels and show
--   both expected and observed packed channel values.
--==============================================================================
package vga_pattern_sim_pkg is

    -- Formats separate RGB channels into a compact simulation report string.
    function rgb_to_string(
        red   : t_rgb_channel;
        green : t_rgb_channel;
        blue  : t_rgb_channel
    ) return string;

    -- Fails the simulation when any RGB channel differs from the expected record.
    procedure assert_rgb_equal(
        actual_red   : t_rgb_channel;
        actual_green : t_rgb_channel;
        actual_blue  : t_rgb_channel;
        expected     : t_rgb_color;
        message      : string
    );

end package vga_pattern_sim_pkg;

package body vga_pattern_sim_pkg is

    -- Simulation formatting helper; not intended for synthesis.
    function rgb_to_string(
        red   : t_rgb_channel;
        green : t_rgb_channel;
        blue  : t_rgb_channel
    ) return string is
    begin
        return "R=" & integer'image(to_integer(unsigned(red))) &
               " G=" & integer'image(to_integer(unsigned(green))) &
               " B=" & integer'image(to_integer(unsigned(blue)));
    end function;

    -- Shared RGB equality assertion used by the pattern generator testbenches.
    procedure assert_rgb_equal(
        actual_red   : t_rgb_channel;
        actual_green : t_rgb_channel;
        actual_blue  : t_rgb_channel;
        expected     : t_rgb_color;
        message      : string
    ) is
    begin
        assert (actual_red = expected.red) and
               (actual_green = expected.green) and
               (actual_blue = expected.blue)
            report message &
                   " Expected " &
                   rgb_to_string(expected.red, expected.green, expected.blue) &
                   ", got " &
                   rgb_to_string(actual_red, actual_green, actual_blue)
            severity failure;
    end procedure;

end package body vga_pattern_sim_pkg;
