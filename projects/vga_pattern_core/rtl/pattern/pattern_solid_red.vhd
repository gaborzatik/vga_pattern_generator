library ieee;
use ieee.std_logic_1164.all;

entity pattern_solid_red is
    port (
        video_on_i : in  std_logic;
        rgb_o      : out work.vga_pattern_common_pkg.t_rgb_color
    );
end entity pattern_solid_red;

architecture rtl of pattern_solid_red is
begin
    rgb_o <= work.vga_pattern_common_pkg.C_RGB_RED  when video_on_i = '1' 
                                                    else work.vga_pattern_common_pkg.C_RGB_BLACK;
end architecture rtl;
