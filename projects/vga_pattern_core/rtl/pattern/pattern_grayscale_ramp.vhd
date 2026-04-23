library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;
use work.vga_pattern_gray_pkg.all;

entity pattern_grayscale_ramp is
    generic (
        G_VGA_MODE : t_vga_mode := VGA_640X480_60
    );
    port (
        video_on_i : in  std_logic;
        x_i        : in  unsigned(get_x_coord_width(G_VGA_MODE) - 1 downto 0);
        rgb_o      : out t_rgb_color
    );
end entity pattern_grayscale_ramp;

architecture rtl of pattern_grayscale_ramp is
    constant C_TIMING       : t_vga_timing := get_vga_timing(G_VGA_MODE);
    constant C_ACTIVE_WIDTH : natural := C_TIMING.h_addr_video;
begin

    process(video_on_i, x_i)
        variable v_gray_index : natural range 0 to 15;
    begin
        if video_on_i = '1' then
            v_gray_index := (to_integer(x_i) * 16) / C_ACTIVE_WIDTH;

            case v_gray_index is
                when 0 =>
                    rgb_o <= C_RGB_GRAY_0_15;
                when 1 =>
                    rgb_o <= C_RGB_GRAY_1_15;
                when 2 =>
                    rgb_o <= C_RGB_GRAY_2_15;
                when 3 =>
                    rgb_o <= C_RGB_GRAY_3_15;
                when 4 =>
                    rgb_o <= C_RGB_GRAY_4_15;
                when 5 =>
                    rgb_o <= C_RGB_GRAY_5_15;
                when 6 =>
                    rgb_o <= C_RGB_GRAY_6_15;
                when 7 =>
                    rgb_o <= C_RGB_GRAY_7_15;
                when 8 =>
                    rgb_o <= C_RGB_GRAY_8_15;
                when 9 =>
                    rgb_o <= C_RGB_GRAY_9_15;
                when 10 =>
                    rgb_o <= C_RGB_GRAY_10_15;
                when 11 =>
                    rgb_o <= C_RGB_GRAY_11_15;
                when 12 =>
                    rgb_o <= C_RGB_GRAY_12_15;
                when 13 =>
                    rgb_o <= C_RGB_GRAY_13_15;
                when 14 =>
                    rgb_o <= C_RGB_GRAY_14_15;
                when others =>
                    rgb_o <= C_RGB_GRAY_15_15;
            end case;
        else
            rgb_o <= C_RGB_GRAY_0_15;
        end if;
    end process;

end architecture rtl;
