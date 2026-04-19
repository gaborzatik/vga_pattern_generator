library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pattern_checker is
    generic (
        G_X_WIDTH : natural := 10;
        G_Y_WIDTH : natural := 10
    );
    port (
        checker_pixel_i : in  unsigned(1 downto 0);  -- 00:1px, 01:2px, 10:4px, 11:8px
        video_on_i      : in  std_logic;
        x_i             : in  unsigned(G_X_WIDTH - 1 downto 0);
        y_i             : in  unsigned(G_Y_WIDTH - 1 downto 0);
        rgb_o           : out work.vga_pattern_common_pkg.t_rgb_color
    );
end entity pattern_checker;

architecture rtl of pattern_checker is
    signal checker_white_s : std_logic;
begin

    with checker_pixel_i select
        checker_white_s <=
            (x_i(0) xor y_i(0)) when "00",  -- 1x1
            (x_i(1) xor y_i(1)) when "01",  -- 2x2
            (x_i(2) xor y_i(2)) when "10",  -- 4x4
            (x_i(3) xor y_i(3)) when others;-- 8x8

    rgb_o <= work.vga_pattern_common_pkg.C_RGB_WHITE when (video_on_i = '1' and checker_white_s = '1')
                                                     else work.vga_pattern_common_pkg.C_RGB_BLACK;

end architecture rtl;