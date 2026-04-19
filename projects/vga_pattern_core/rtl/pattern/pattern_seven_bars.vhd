library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pattern_seven_bars is
    generic (
        G_X_WIDTH       : natural := 10;
        G_ACTIVE_WIDTH  : natural := 640
--        G_VGA_MODE      : work.vga_timing_pkg.t_vga_mode := work.vga_timing_pkg.VGA_640X480_60
    );
    port (
        video_on_i      : in  std_logic;
        x_i             : in  unsigned(G_X_WIDTH - 1 downto 0);

        rgb_o           : out work.vga_pattern_common_pkg.t_rgb_color
    );
end entity pattern_seven_bars;

architecture rtl of pattern_seven_bars is
begin
-- it is prepared for 640x480
    process(video_on_i, x_i)
    begin
        if video_on_i = '0' then
            rgb_o <= work.vga_pattern_common_pkg.C_RGB_BLACK;
        else
            case (to_integer(x_i)) is
                when 0 to 90 => 
                    rgb_o <= work.vga_pattern_common_pkg.C_RGB_WHITE;
                when 91 to 182  => 
                    rgb_o <= work.vga_pattern_common_pkg.C_RGB_YELLOW;
                when 183 to 273 => 
                    rgb_o <= work.vga_pattern_common_pkg.C_RGB_CYAN;
                when 274 to 365 => 
                    rgb_o <= work.vga_pattern_common_pkg.C_RGB_GREEN;
                when 366 to 456 => 
                    rgb_o <= work.vga_pattern_common_pkg.C_RGB_MAGENTA;
                when 457 to 548 => 
                    rgb_o <= work.vga_pattern_common_pkg.C_RGB_RED;
                when 549 to 639 => 
                    rgb_o <= work.vga_pattern_common_pkg.C_RGB_BLUE;
                when others => 
                    rgb_o <= work.vga_pattern_common_pkg.C_RGB_BLACK;
                end case;
            end if;
    end process;

end architecture rtl;
