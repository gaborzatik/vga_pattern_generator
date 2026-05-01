--==============================================================================
-- File        : pattern_checker.vhd
-- Project     : vga_pattern_core
-- Unit        : pattern_checker
--
-- Description :
--   Generates a two-color checker pattern from one selected x coordinate bit and
--   one selected y coordinate bit.
--
-- Project role:
--   Reusable checker primitive instantiated by vga_pattern_generator for 1, 2,
--   4, and 8 pixel checker sizes.
--
-- Design level:
--   RTL pattern block.
--
-- Clock/reset:
--   No clock or reset; combinational logic in the pixel-coordinate path.
--
-- Synthesis:
--   Synthesizable combinational RTL.
--
-- Review notes:
--   Checker size is not a generic here. The integrating module selects which
--   coordinate bits drive x_bit_i/y_bit_i.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_pattern_common_pkg.all;

--==============================================================================
-- Entity: pattern_checker
--
-- Purpose:
--   Produces black/white checker pixels inside video_on_i by XORing the selected
--   coordinate bits supplied by the parent.
--
-- Interface groups:
--   video_on_i qualifies the addressable pattern area; x_bit_i and y_bit_i are
--   already-selected coordinate bits; rgb_o is the combinational RGB result.
--
-- Output semantics:
--   White is produced when exactly one selected coordinate bit is high and
--   video_on_i is high; otherwise the output is black.
--==============================================================================
entity pattern_checker is
    port (
        video_on_i : in  std_logic;
        x_bit_i    : in  std_logic;
        y_bit_i    : in  std_logic;
        rgb_o      : out t_rgb_color
    );
end entity pattern_checker;

architecture rtl of pattern_checker is
    -- Internal checker phase after parent-selected coordinate-bit sampling.
    signal checker_white_s : std_logic;
begin

    checker_white_s <= x_bit_i xor y_bit_i;

    rgb_o <= C_RGB_WHITE when (video_on_i = '1' and checker_white_s = '1')
                     else C_RGB_BLACK;

end architecture rtl;
