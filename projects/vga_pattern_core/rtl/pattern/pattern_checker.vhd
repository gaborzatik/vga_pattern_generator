library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_pattern_common_pkg.all;

entity pattern_checker is
    port (
        video_on_i : in  std_logic;
        x_bit_i    : in  std_logic;
        y_bit_i    : in  std_logic;
        rgb_o      : out t_rgb_color
    );
end entity pattern_checker;

architecture rtl of pattern_checker is
    signal checker_white_s : std_logic;
begin

    checker_white_s <= x_bit_i xor y_bit_i;

    rgb_o <= C_RGB_WHITE when (video_on_i = '1' and checker_white_s = '1')
                     else C_RGB_BLACK;

end architecture rtl;
