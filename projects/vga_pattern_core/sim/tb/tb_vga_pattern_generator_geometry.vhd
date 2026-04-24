library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;
use work.vga_pattern_sim_pkg.all;

entity tb_vga_pattern_generator_geometry is
end entity tb_vga_pattern_generator_geometry;

architecture sim of tb_vga_pattern_generator_geometry is

    constant C_MODE          : t_vga_mode := VGA_640X480_60;
    constant C_X_WIDTH       : natural := get_x_coord_width(C_MODE);
    constant C_Y_WIDTH       : natural := get_y_coord_width(C_MODE);
    constant C_ACTIVE_WIDTH  : natural := get_vga_timing(C_MODE).h_addr_video;
    constant C_ACTIVE_HEIGHT : natural := get_vga_timing(C_MODE).v_addr_video;

    signal pattern_sel_s     : t_pattern_sel_slv := pattern_select_from_mode(BLACK);
    signal video_on_s        : std_logic := '1';
    signal x_s               : unsigned(C_X_WIDTH - 1 downto 0) := (others => '0');
    signal y_s               : unsigned(C_Y_WIDTH - 1 downto 0) := (others => '0');
    signal red_s             : t_rgb_channel;
    signal green_s           : t_rgb_channel;
    signal blue_s            : t_rgb_channel;

    function color_bar_expected(
        index : natural
    ) return t_rgb_color is
    begin
        case index is
            when 0 =>
                return C_RGB_WHITE;
            when 1 =>
                return C_RGB_YELLOW;
            when 2 =>
                return C_RGB_CYAN;
            when 3 =>
                return C_RGB_GREEN;
            when 4 =>
                return C_RGB_MAGENTA;
            when 5 =>
                return C_RGB_RED;
            when others =>
                return C_RGB_BLUE;
        end case;
    end function;

    procedure drive_and_expect(
        constant mode     : t_pattern_mode;
        constant x_coord  : natural;
        constant y_coord  : natural;
        constant video_on : std_logic;
        constant expected : t_rgb_color;
        constant message  : string
    ) is
    begin
        pattern_sel_s <= pattern_select_from_mode(mode);
        x_s           <= to_unsigned(x_coord, x_s'length);
        y_s           <= to_unsigned(y_coord, y_s'length);
        video_on_s    <= video_on;
        wait for 1 ns;

        assert_rgb_equal(
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
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
        variable sample_x_v : natural;
    begin
        drive_and_expect(
            mode     => BORDER_1PX,
            x_coord  => 0,
            y_coord  => 0,
            video_on => '1',
            expected => C_RGB_GREEN,
            message  => "Top-left border pixel mismatch."
        );
        drive_and_expect(
            mode     => BORDER_1PX,
            x_coord  => C_ACTIVE_WIDTH - 1,
            y_coord  => C_ACTIVE_HEIGHT - 1,
            video_on => '1',
            expected => C_RGB_GREEN,
            message  => "Bottom-right border pixel mismatch."
        );
        drive_and_expect(
            mode     => BORDER_1PX,
            x_coord  => 1,
            y_coord  => 1,
            video_on => '1',
            expected => C_RGB_BLUE,
            message  => "Interior border pattern pixel mismatch."
        );
        drive_and_expect(
            mode     => BORDER_1PX,
            x_coord  => 10,
            y_coord  => 10,
            video_on => '0',
            expected => C_RGB_BLACK,
            message  => "Border pattern must blank when video_on_i is low."
        );

        drive_and_expect(
            mode     => CHECKER_1PX,
            x_coord  => 0,
            y_coord  => 0,
            video_on => '1',
            expected => C_RGB_BLACK,
            message  => "CHECKER_1PX origin mismatch."
        );
        drive_and_expect(
            mode     => CHECKER_1PX,
            x_coord  => 1,
            y_coord  => 0,
            video_on => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_1PX adjacent pixel mismatch."
        );
        drive_and_expect(
            mode     => CHECKER_2PX,
            x_coord  => 2,
            y_coord  => 0,
            video_on => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_2PX block transition mismatch."
        );
        drive_and_expect(
            mode     => CHECKER_2PX,
            x_coord  => 2,
            y_coord  => 2,
            video_on => '1',
            expected => C_RGB_BLACK,
            message  => "CHECKER_2PX diagonal block mismatch."
        );
        drive_and_expect(
            mode     => CHECKER_4PX,
            x_coord  => 4,
            y_coord  => 0,
            video_on => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_4PX block transition mismatch."
        );
        drive_and_expect(
            mode     => CHECKER_8PX,
            x_coord  => 8,
            y_coord  => 8,
            video_on => '1',
            expected => C_RGB_BLACK,
            message  => "CHECKER_8PX diagonal block mismatch."
        );

        for bar_idx_v in 0 to 6 loop
            sample_x_v := ((2 * bar_idx_v + 1) * C_ACTIVE_WIDTH) / 14;
            if sample_x_v >= C_ACTIVE_WIDTH then
                sample_x_v := C_ACTIVE_WIDTH - 1;
            end if;

            drive_and_expect(
                mode     => COLOR_BARS,
                x_coord  => sample_x_v,
                y_coord  => 40,
                video_on => '1',
                expected => color_bar_expected(bar_idx_v),
                message  => "COLOR_BARS mismatch at bar index " & integer'image(bar_idx_v) & "."
            );
        end loop;

        for gray_idx_v in 0 to 15 loop
            sample_x_v := ((2 * gray_idx_v + 1) * C_ACTIVE_WIDTH) / 32;
            if sample_x_v >= C_ACTIVE_WIDTH then
                sample_x_v := C_ACTIVE_WIDTH - 1;
            end if;

            drive_and_expect(
                mode     => GRAYSCALE_RAMP,
                x_coord  => sample_x_v,
                y_coord  => 40,
                video_on => '1',
                expected => gray_color_from_level(gray_idx_v),
                message  => "GRAYSCALE_RAMP mismatch at gray index " & integer'image(gray_idx_v) & "."
            );
        end loop;

        report "tb_vga_pattern_generator_geometry completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
