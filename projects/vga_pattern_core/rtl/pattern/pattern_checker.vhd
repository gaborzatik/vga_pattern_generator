library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_pattern_common_pkg.all;

entity pattern_checker is
    generic (
        G_X_WIDTH : natural := 10;
        G_Y_WIDTH : natural := 10
    );
    port (
        checker_pixel_i : in  t_checker_pixel_mode;
        video_on_i      : in  std_logic;
        x_i             : in  unsigned(G_X_WIDTH - 1 downto 0);
        y_i             : in  unsigned(G_Y_WIDTH - 1 downto 0);
        rgb_o           : out t_rgb_color
    );
end entity pattern_checker;

architecture rtl of pattern_checker is
    signal checker_white_s : std_logic;
begin

    with checker_pixel_i select
        checker_white_s <=
            (x_i(0) xor y_i(0)) when CHECKER_PIXEL_1,
            (x_i(1) xor y_i(1)) when CHECKER_PIXEL_2,
            (x_i(2) xor y_i(2)) when CHECKER_PIXEL_4,
            (x_i(3) xor y_i(3)) when CHECKER_PIXEL_8;

    rgb_o <= C_RGB_WHITE when (video_on_i = '1' and checker_white_s = '1')
                      else C_RGB_BLACK;

end architecture rtl;
