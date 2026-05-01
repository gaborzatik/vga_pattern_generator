--==============================================================================
-- File        : pattern_seven_bars.vhd
-- Project     : vga_pattern_core
-- Unit        : pattern_seven_bars
--
-- Description :
--   Generates seven vertical color bars across the addressable video width.
--
-- Project role:
--   Coordinate-dependent pattern source selected by vga_pattern_generator.
--
-- Design level:
--   RTL pattern block.
--
-- Clock/reset:
--   No clock or reset; combinational logic driven by video_on_i and x_i.
--
-- Synthesis:
--   Synthesizable combinational RTL.
--
-- Review notes:
--   Bar boundaries are derived from the selected mode's addressable width, not
--   from any board-level border or sync interval.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;

--==============================================================================
-- Entity: pattern_seven_bars
--
-- Purpose:
--   Converts the horizontal coordinate into a standard seven-color bar sample.
--
-- Interface groups:
--   G_VGA_MODE selects horizontal active width; video_on_i qualifies the
--   addressable pattern area; x_i is the current horizontal coordinate; rgb_o is
--   the combinational color-bar result.
--
-- Output semantics:
--   Inactive samples return black; active samples return one of seven bar colors.
--==============================================================================
entity pattern_seven_bars is
    generic (
        G_VGA_MODE : t_vga_mode := VGA_640X480_60
    );
    port (
        video_on_i : in  std_logic;
        x_i        : in  unsigned(get_x_coord_width(G_VGA_MODE) - 1 downto 0);
        rgb_o      : out t_rgb_color
    );
end entity pattern_seven_bars;

architecture rtl of pattern_seven_bars is
    -- Elaborated timing constants determine the horizontal bar partitioning.
    constant C_TIMING       : t_vga_timing := get_vga_timing(G_VGA_MODE);
    constant C_ACTIVE_WIDTH : natural := C_TIMING.h_addr_video;
begin

    -- Combinational color-bar lookup. The arithmetic bins x_i into seven regions
    -- using the addressable width from the timing package.
    process(video_on_i, x_i)
        variable v_bar_index : natural range 0 to 6;
    begin
        if video_on_i = '0' then
            rgb_o <= C_RGB_BLACK;
        else
            v_bar_index := (to_integer(x_i) * 7) / C_ACTIVE_WIDTH;

            case v_bar_index is
                when 0 =>
                    rgb_o <= C_RGB_WHITE;
                when 1 =>
                    rgb_o <= C_RGB_YELLOW;
                when 2 =>
                    rgb_o <= C_RGB_CYAN;
                when 3 =>
                    rgb_o <= C_RGB_GREEN;
                when 4 =>
                    rgb_o <= C_RGB_MAGENTA;
                when 5 =>
                    rgb_o <= C_RGB_RED;
                when others =>
                    rgb_o <= C_RGB_BLUE;
            end case;
        end if;
    end process;

end architecture rtl;
