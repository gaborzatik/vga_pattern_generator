--==============================================================================
-- File        : pattern_solid_blue.vhd
-- Project     : vga_pattern_core
-- Unit        : pattern_solid_blue
--
-- Description :
--   Generates a blue fill while the addressable pattern area is active.
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
--   This block intentionally ignores pixel coordinates because solid blue has no
--   spatial dependence.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;

--==============================================================================
-- Entity: pattern_solid_blue
--
-- Purpose:
--   Provides a video_on_i-qualified blue RGB record using the common pattern
--   output type.
--
-- Interface groups:
--   video_on_i qualifies the addressable pattern-generation area; rgb_o is the
--   combinational RGB result.
--
-- Output semantics:
--   Blue when video_on_i is high, black otherwise.
--==============================================================================
entity pattern_solid_blue is
    port (
        video_on_i : in  std_logic;
        rgb_o      : out work.vga_pattern_common_pkg.t_rgb_color
    );
end pattern_solid_blue;

architecture Behavioral of pattern_solid_blue is

begin
    -- Blanks outside video_on_i so inactive addressable samples do not leak the
    -- solid color through the top-level mux.
    rgb_o <= work.vga_pattern_common_pkg.C_RGB_BLUE when video_on_i = '1' 
                                                    else work.vga_pattern_common_pkg.C_RGB_BLACK;
end Behavioral;
