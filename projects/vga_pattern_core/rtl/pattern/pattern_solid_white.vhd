--==============================================================================
-- File        : pattern_solid_white.vhd
-- Project     : vga_pattern_core
-- Unit        : pattern_solid_white
--
-- Description :
--   Generates a white fill while the addressable pattern area is active.
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
--   x/y coordinates are intentionally absent because this solid pattern does not
--   depend on pixel position.
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;

--==============================================================================
-- Entity: pattern_solid_white
--
-- Purpose:
--   Provides a video_on_i-qualified white RGB record using the common pattern
--   output type.
--
-- Interface groups:
--   video_on_i qualifies the addressable pattern-generation area; rgb_o is the
--   combinational RGB result.
--
-- Output semantics:
--   White when video_on_i is high, black otherwise.
--==============================================================================
entity pattern_solid_white is
    port (
        video_on_i : in  std_logic;
        rgb_o      : out work.vga_pattern_common_pkg.t_rgb_color
    );
end pattern_solid_white;

architecture Behavioral of pattern_solid_white is
begin
    -- Blanks outside video_on_i so the top-level mux can combine this pattern
    -- with other video_on_i-qualified generators.
    rgb_o <= work.vga_pattern_common_pkg.C_RGB_WHITE    when video_on_i = '1' 
                                                        else work.vga_pattern_common_pkg.C_RGB_BLACK;
end Behavioral;
