library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_pattern_common_pkg.all;

package vga_pattern_sim_pkg is

    function rgb_to_string(
        red   : t_rgb_channel;
        green : t_rgb_channel;
        blue  : t_rgb_channel
    ) return string;

    procedure assert_rgb_equal(
        actual_red   : t_rgb_channel;
        actual_green : t_rgb_channel;
        actual_blue  : t_rgb_channel;
        expected     : t_rgb_color;
        message      : string
    );

end package vga_pattern_sim_pkg;

package body vga_pattern_sim_pkg is

    function rgb_to_string(
        red   : t_rgb_channel;
        green : t_rgb_channel;
        blue  : t_rgb_channel
    ) return string is
    begin
        return "R=" & integer'image(to_integer(unsigned(red))) &
               " G=" & integer'image(to_integer(unsigned(green))) &
               " B=" & integer'image(to_integer(unsigned(blue)));
    end function;

    procedure assert_rgb_equal(
        actual_red   : t_rgb_channel;
        actual_green : t_rgb_channel;
        actual_blue  : t_rgb_channel;
        expected     : t_rgb_color;
        message      : string
    ) is
    begin
        assert (actual_red = expected.red) and
               (actual_green = expected.green) and
               (actual_blue = expected.blue)
            report message &
                   " Expected " &
                   rgb_to_string(expected.red, expected.green, expected.blue) &
                   ", got " &
                   rgb_to_string(actual_red, actual_green, actual_blue)
            severity failure;
    end procedure;

end package body vga_pattern_sim_pkg;
