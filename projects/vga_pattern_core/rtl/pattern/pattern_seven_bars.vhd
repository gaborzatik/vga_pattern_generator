library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;

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
    constant C_TIMING       : t_vga_timing := get_vga_timing(G_VGA_MODE);
    constant C_ACTIVE_WIDTH : natural := C_TIMING.h_addr_video;
begin

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
