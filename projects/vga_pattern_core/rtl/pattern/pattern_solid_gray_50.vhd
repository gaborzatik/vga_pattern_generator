--==============================================================================
-- File        : pattern_solid_gray_50.vhd
-- Project     : vga_pattern_core
-- Unit        : pattern_solid_gray_50
--
-- Description :
--   Generates the mid-intensity gray fill used for the GRAY_50 selector.
--
-- Project role:
--   Coordinate-independent solid pattern source selected by vga_pattern_generator.
--
-- Design level:
--   RTL pattern block.
--
-- Clock/reset:
--   No clock or reset; combinational logic gated by video_on_i.
--
-- Synthesis:
--   Synthesizable combinational RTL.
--
-- Review notes:
--   Uses the package-defined 7/15 gray level; review brightness expectations
--   against vga_pattern_gray_pkg rather than local literals.
--==============================================================================


library ieee;
use ieee.std_logic_1164.all;

--==============================================================================
-- Entity: pattern_solid_gray_50
--
-- Purpose:
--   Provides a video_on_i-qualified mid-gray RGB record using the common pattern
--   output type.
--
-- Interface groups:
--   video_on_i qualifies the addressable pattern-generation area; rgb_o is the
--   combinational RGB result.
--
-- Output semantics:
--   C_RGB_GRAY_7_15 when video_on_i is high, C_RGB_GRAY_0_15 otherwise.
--==============================================================================
entity pattern_solid_gray_50 is
    port (
        video_on_i : in  std_logic;
        rgb_o      : out work.vga_pattern_common_pkg.t_rgb_color
    );
end pattern_solid_gray_50;

architecture Behavioral of pattern_solid_gray_50 is
begin
    -- Blanks to the grayscale package's black level outside video_on_i.
    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_7_15  when video_on_i = '1' 
                                                        else work.vga_pattern_gray_pkg.C_RGB_GRAY_0_15;
end Behavioral;
