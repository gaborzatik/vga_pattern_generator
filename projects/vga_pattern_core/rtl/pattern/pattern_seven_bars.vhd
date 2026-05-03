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
--   mode_i selects horizontal active width; video_on_i qualifies the
--   addressable pattern area; x_i is the current horizontal coordinate; rgb_o is
--   the combinational color-bar result.
--
-- Output semantics:
--   Inactive samples return black; active samples return one of seven bar colors.
--==============================================================================
entity pattern_seven_bars is
    port (
        video_on_i : in  std_logic;
        mode_i     : in  t_vga_mode;
        x_i        : in  unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
        rgb_o      : out t_rgb_color
    );
end entity pattern_seven_bars;

architecture rtl of pattern_seven_bars is
    function f_bar_index_from_edges(
        constant x_value : natural;
        constant edge_1  : natural;
        constant edge_2  : natural;
        constant edge_3  : natural;
        constant edge_4  : natural;
        constant edge_5  : natural;
        constant edge_6  : natural
    ) return natural is
    begin
        if x_value < edge_1 then
            return 0;
        elsif x_value < edge_2 then
            return 1;
        elsif x_value < edge_3 then
            return 2;
        elsif x_value < edge_4 then
            return 3;
        elsif x_value < edge_5 then
            return 4;
        elsif x_value < edge_6 then
            return 5;
        else
            return 6;
        end if;
    end function;

    function f_bar_index(
        constant mode    : t_vga_mode;
        constant x_value : natural
    ) return natural is
    begin
        case mode is
            when VGA_640X480_60 =>
                return f_bar_index_from_edges(x_value, 92, 183, 275, 366, 458, 549);
            when SVGA_800X600_60 =>
                return f_bar_index_from_edges(x_value, 115, 229, 343, 458, 572, 686);
            when XGA_1024X768_60 =>
                return f_bar_index_from_edges(x_value, 147, 293, 439, 586, 732, 878);
        end case;
    end function;
begin

    -- Combinational color-bar lookup. The fixed edges are equivalent to
    -- floor(x * 7 / active_width) for each supported mode, without inferring a
    -- runtime divider on the pixel path.
    process(video_on_i, mode_i, x_i)
        variable v_bar_index : natural range 0 to 6;
    begin
        if video_on_i = '0' then
            rgb_o <= C_RGB_BLACK;
        else
            v_bar_index := f_bar_index(mode_i, to_integer(x_i));

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
