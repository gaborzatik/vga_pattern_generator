--==============================================================================
-- File        : pattern_solid_black.vhd
-- Project     : vga_pattern_core
-- Unit        : pattern_solid_black
--
-- Description :
--   Generates the constant black RGB pattern.
--
-- Project role:
--   Coordinate-independent solid pattern source selected by vga_pattern_generator.
--
-- Design level:
--   RTL pattern block.
--
-- Clock/reset:
--   No clock or reset; constant combinational output.
--
-- Synthesis:
--   Synthesizable combinational RTL.
--
-- Review notes:
--   This pattern has no video_on_i port because black is identical inside and
--   outside the addressable pattern-generation area.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;

--==============================================================================
-- Entity: pattern_solid_black
--
-- Purpose:
--   Provides a constant black RGB record for selector fallback and explicit
--   black-pattern output.
--
-- Interface groups:
--   rgb_o is the only output. There are intentionally no coordinate, clock, or
--   reset ports.
--
-- Output semantics:
--   Always drives C_RGB_BLACK.
--==============================================================================
entity pattern_solid_black is
    port (
        rgb_o      : out work.vga_pattern_common_pkg.t_rgb_color
    );
end pattern_solid_black;

architecture Behavioral of pattern_solid_black is
begin
    -- Constant combinational output; no coordinate or video qualifier is needed.
    rgb_o <= work.vga_pattern_common_pkg.C_RGB_BLACK;
end Behavioral;
