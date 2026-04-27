library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;
use work.vga_pattern_gray_pkg.all;
use work.vga_pattern_sim_pkg.all;

entity tb_vga_pattern_generator_solid_colors is
end entity tb_vga_pattern_generator_solid_colors;

architecture sim of tb_vga_pattern_generator_solid_colors is

    constant C_MODE          : t_vga_mode := VGA_640X480_60;
    constant C_X_WIDTH       : natural := get_x_coord_width(C_MODE);
    constant C_Y_WIDTH       : natural := get_y_coord_width(C_MODE);
    constant C_ACTIVE_WIDTH  : natural := get_vga_timing(C_MODE).h_addr_video;
    constant C_ACTIVE_HEIGHT : natural := get_vga_timing(C_MODE).v_addr_video;

    signal pattern_sel_s     : t_pattern_sel_slv := pattern_select_from_mode(BLACK);
    signal video_on_s        : std_logic := '0';
    signal x_s               : unsigned(C_X_WIDTH - 1 downto 0) := to_unsigned(17, C_X_WIDTH);
    signal y_s               : unsigned(C_Y_WIDTH - 1 downto 0) := to_unsigned(23, C_Y_WIDTH);
    signal red_s             : t_rgb_channel;
    signal green_s           : t_rgb_channel;
    signal blue_s            : t_rgb_channel;

    procedure drive_and_expect(
        signal pattern_sel : out t_pattern_sel_slv;
        signal video_on    : out std_logic;
        signal actual_red  : in  t_rgb_channel;
        signal actual_green: in  t_rgb_channel;
        signal actual_blue : in  t_rgb_channel;
        constant mode     : t_pattern_mode;
        constant video_on_value : std_logic;
        constant expected : t_rgb_color;
        constant message  : string
    ) is
    begin
        pattern_sel <= pattern_select_from_mode(mode);
        video_on    <= video_on_value;
        wait for 1 ns;

        assert_rgb_equal(
            actual_red   => actual_red,
            actual_green => actual_green,
            actual_blue  => actual_blue,
            expected     => expected,
            message      => message
        );
    end procedure;

begin

    dut : entity work.vga_pattern_generator
        generic map (
            G_VGA_MODE      => C_MODE,
            G_X_WIDTH       => C_X_WIDTH,
            G_Y_WIDTH       => C_Y_WIDTH,
            G_ACTIVE_WIDTH  => C_ACTIVE_WIDTH,
            G_ACTIVE_HEIGHT => C_ACTIVE_HEIGHT
        )
        port map (
            pattern_sel_i => pattern_sel_s,
            video_on_i    => video_on_s,
            x_i           => x_s,
            y_i           => y_s,
            red_o         => red_s,
            green_o       => green_s,
            blue_o        => blue_s
        );

    stimulus : process
    begin
        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => BLACK,
            video_on_value => '0',
            expected => C_RGB_BLACK,
            message  => "BLACK must stay black when video_on_i is low."
        );
        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => BLACK,
            video_on_value => '1',
            expected => C_RGB_BLACK,
            message  => "BLACK must stay black when video_on_i is high."
        );

        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => WHITE,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "WHITE mismatch while video_on_i is high."
        );
        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => WHITE,
            video_on_value => '0',
            expected => C_RGB_BLACK,
            message  => "WHITE must blank outside the addressable region."
        );

        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => RED,
            video_on_value => '1',
            expected => C_RGB_RED,
            message  => "RED mismatch while video_on_i is high."
        );
        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => RED,
            video_on_value => '0',
            expected => C_RGB_BLACK,
            message  => "RED must blank outside the addressable region."
        );

        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => GREEN,
            video_on_value => '1',
            expected => C_RGB_GREEN,
            message  => "GREEN mismatch while video_on_i is high."
        );
        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => GREEN,
            video_on_value => '0',
            expected => C_RGB_BLACK,
            message  => "GREEN must blank outside the addressable region."
        );

        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => BLUE,
            video_on_value => '1',
            expected => C_RGB_BLUE,
            message  => "BLUE mismatch while video_on_i is high."
        );
        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => BLUE,
            video_on_value => '0',
            expected => C_RGB_BLACK,
            message  => "BLUE must blank outside the addressable region."
        );

        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => GRAY_10,
            video_on_value => '1',
            expected => C_RGB_GRAY_1_15,
            message  => "GRAY_10 mismatch while video_on_i is high."
        );
        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => GRAY_10,
            video_on_value => '0',
            expected => C_RGB_GRAY_0_15,
            message  => "GRAY_10 must blank outside the addressable region."
        );

        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => GRAY_50,
            video_on_value => '1',
            expected => C_RGB_GRAY_7_15,
            message  => "GRAY_50 mismatch while video_on_i is high."
        );
        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => GRAY_50,
            video_on_value => '0',
            expected => C_RGB_GRAY_0_15,
            message  => "GRAY_50 must blank outside the addressable region."
        );

        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => GRAY_80,
            video_on_value => '1',
            expected => C_RGB_GRAY_11_15,
            message  => "GRAY_80 mismatch while video_on_i is high."
        );
        drive_and_expect(
            pattern_sel => pattern_sel_s,
            video_on    => video_on_s,
            actual_red  => red_s,
            actual_green=> green_s,
            actual_blue => blue_s,
            mode     => GRAY_80,
            video_on_value => '0',
            expected => C_RGB_GRAY_0_15,
            message  => "GRAY_80 must blank outside the addressable region."
        );

        report "tb_vga_pattern_generator_solid_colors completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
