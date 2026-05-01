--==============================================================================
-- File        : pattern_solid_red.vhd
-- Project     : vga_pattern_core
-- Unit        : pattern_solid_red
--
-- Description :
--   Generates a red fill while the addressable pattern area is active.
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
--   This block intentionally ignores pixel coordinates because solid red has no
--   spatial dependence.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;

--==============================================================================
-- Entity: pattern_solid_red
--
-- Purpose:
--   Provides a video_on_i-qualified red RGB record using the common pattern
--   output type.
--
-- Interface groups:
--   video_on_i qualifies the addressable pattern-generation area; rgb_o is the
--   combinational RGB result.
--
-- Output semantics:
--   Red when video_on_i is high, black otherwise.
--==============================================================================
entity pattern_solid_red is
    port (
        video_on_i : in  std_logic;
        rgb_o      : out work.vga_pattern_common_pkg.t_rgb_color
    );
end entity pattern_solid_red;

architecture rtl of pattern_solid_red is
begin
    -- Blanks outside video_on_i so inactive addressable samples do not leak the
    -- solid color through the top-level mux.
    rgb_o <= work.vga_pattern_common_pkg.C_RGB_RED  when video_on_i = '1' 
                                                    else work.vga_pattern_common_pkg.C_RGB_BLACK;
end architecture rtl;
