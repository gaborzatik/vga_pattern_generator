--==============================================================================
-- File        : tb_vga_pattern_generator_geometry.vhd
-- Project     : vga_pattern_core
-- Unit        : tb_vga_pattern_generator_geometry
--
-- Description :
--   Verifies coordinate-dependent pattern behavior for border, checker, color
--   bars, and grayscale-ramp modes.
--
-- Project role:
--   Simulation testbench for the vga_pattern_generator geometry path.
--
-- Design level:
--   Testbench.
--
-- Clock/reset:
--   No clock or reset stimulus; the DUT behavior checked here is combinational.
--
-- Synthesis:
--   Simulation-only.
--
-- Review notes:
--   Samples targeted coordinates rather than every pixel. The test distinguishes
--   video_on_i as the addressable pattern area qualifier.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;
use work.vga_pattern_sim_pkg.all;

--==============================================================================
-- Entity: tb_vga_pattern_generator_geometry
--
-- Purpose:
--   Top-level simulation wrapper with no ports. The pass condition is reaching
--   std.env.finish after all geometry-sensitive assertions complete.
--
-- Verification scope:
--   Checks border edge/interior behavior, checker bit selection, representative
--   seven-bar centers, and representative grayscale-ramp bin centers.
--==============================================================================
entity tb_vga_pattern_generator_geometry is
end entity tb_vga_pattern_generator_geometry;

architecture sim of tb_vga_pattern_generator_geometry is

    -- Main samples use VGA first, then the same DUT runtime mode input is
    -- switched to the larger supported geometries near the end of the test.
    constant C_MODE          : t_vga_mode := VGA_640X480_60;
    constant C_ACTIVE_WIDTH  : natural := get_vga_timing(C_MODE).h_addr_video;
    constant C_ACTIVE_HEIGHT : natural := get_vga_timing(C_MODE).v_addr_video;

    signal pattern_sel_s     : t_pattern_sel_slv := pattern_select_from_mode(BLACK);
    signal mode_s            : t_vga_mode := C_MODE;
    signal video_on_s        : std_logic := '1';
    signal x_s               : unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0) := (others => '0');
    signal y_s               : unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0) := (others => '0');
    signal red_s             : t_rgb_channel;
    signal green_s           : t_rgb_channel;
    signal blue_s            : t_rgb_channel;

    -- Expected color order for the seven-bar generator. This mirrors the RTL
    -- ordering so the main stimulus loop can focus on coordinate sampling.
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

    -- Drives selector, coordinate, and video qualifier inputs into the DUT and
    -- checks the resulting RGB sample after combinational settling.
    procedure drive_and_expect(
        signal pattern_sel  : out t_pattern_sel_slv;
        signal video_on     : out std_logic;
        signal x_value      : out unsigned;
        signal y_value      : out unsigned;
        signal actual_red   : in  t_rgb_channel;
        signal actual_green : in  t_rgb_channel;
        signal actual_blue  : in  t_rgb_channel;
        constant mode     : t_pattern_mode;
        constant x_coord  : natural;
        constant y_coord  : natural;
        constant video_on_value : std_logic;
        constant expected : t_rgb_color;
        constant message  : string
    ) is
    begin
        pattern_sel <= pattern_select_from_mode(mode);
        x_value     <= to_unsigned(x_coord, x_value'length);
        y_value     <= to_unsigned(y_coord, y_value'length);
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

    -- Device under test: full generator used to cover selector decoding,
    -- coordinate-dependent pattern instances, and final RGB channel extraction.
    dut : entity work.vga_pattern_generator
        port map (
            pattern_sel_i => pattern_sel_s,
            mode_i        => mode_s,
            video_on_i    => video_on_s,
            x_i           => x_s,
            y_i           => y_s,
            red_o         => red_s,
            green_o       => green_s,
            blue_o        => blue_s
        );

    -- Sequential geometry samples. The loops choose bin centers to avoid
    -- ambiguous checks at bar or grayscale transition boundaries.
    stimulus : process
        variable sample_x_v : natural;
    begin
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => BORDER_1PX,
            x_coord  => 0,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_GREEN,
            message  => "Top-left border pixel mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => BORDER_1PX,
            x_coord  => C_ACTIVE_WIDTH - 1,
            y_coord  => C_ACTIVE_HEIGHT - 1,
            video_on_value => '1',
            expected => C_RGB_GREEN,
            message  => "Bottom-right border pixel mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => BORDER_1PX,
            x_coord  => 1,
            y_coord  => 1,
            video_on_value => '1',
            expected => C_RGB_BLUE,
            message  => "Interior border pattern pixel mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => BORDER_1PX,
            x_coord  => 10,
            y_coord  => 10,
            video_on_value => '0',
            expected => C_RGB_BLACK,
            message  => "Border pattern must blank when video_on_i is low."
        );

        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => CHECKER_1PX,
            x_coord  => 0,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_BLACK,
            message  => "CHECKER_1PX origin mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => CHECKER_1PX,
            x_coord  => 1,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_1PX adjacent pixel mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => CHECKER_2PX,
            x_coord  => 2,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_2PX block transition mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => CHECKER_2PX,
            x_coord  => 2,
            y_coord  => 2,
            video_on_value => '1',
            expected => C_RGB_BLACK,
            message  => "CHECKER_2PX diagonal block mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => CHECKER_4PX,
            x_coord  => 4,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_4PX block transition mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => CHECKER_8PX,
            x_coord  => 8,
            y_coord  => 8,
            video_on_value => '1',
            expected => C_RGB_BLACK,
            message  => "CHECKER_8PX diagonal block mismatch."
        );

        for bar_idx_v in 0 to 6 loop
            sample_x_v := ((2 * bar_idx_v + 1) * C_ACTIVE_WIDTH) / 14;
            if sample_x_v >= C_ACTIVE_WIDTH then
                sample_x_v := C_ACTIVE_WIDTH - 1;
            end if;

            drive_and_expect(
                pattern_sel  => pattern_sel_s,
                video_on     => video_on_s,
                x_value      => x_s,
                y_value      => y_s,
                actual_red   => red_s,
                actual_green => green_s,
                actual_blue  => blue_s,
                mode     => COLOR_BARS,
                x_coord  => sample_x_v,
                y_coord  => 40,
                video_on_value => '1',
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
                pattern_sel  => pattern_sel_s,
                video_on     => video_on_s,
                x_value      => x_s,
                y_value      => y_s,
                actual_red   => red_s,
                actual_green => green_s,
                actual_blue  => blue_s,
                mode     => GRAYSCALE_RAMP,
                x_coord  => sample_x_v,
                y_coord  => 40,
                video_on_value => '1',
                expected => gray_color_from_level(gray_idx_v),
                message  => "GRAYSCALE_RAMP mismatch at gray index " & integer'image(gray_idx_v) & "."
            );
        end loop;

        mode_s <= SVGA_800X600_60;
        wait for 1 ns;
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => BORDER_1PX,
            x_coord  => get_vga_timing(SVGA_800X600_60).h_addr_video - 1,
            y_coord  => get_vga_timing(SVGA_800X600_60).v_addr_video - 1,
            video_on_value => '1',
            expected => C_RGB_GREEN,
            message  => "Runtime SVGA border geometry mismatch."
        );

        mode_s <= XGA_1024X768_60;
        wait for 1 ns;
        sample_x_v := (13 * get_vga_timing(XGA_1024X768_60).h_addr_video) / 14;
        if sample_x_v >= get_vga_timing(XGA_1024X768_60).h_addr_video then
            sample_x_v := get_vga_timing(XGA_1024X768_60).h_addr_video - 1;
        end if;

        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            mode     => COLOR_BARS,
            x_coord  => sample_x_v,
            y_coord  => 40,
            video_on_value => '1',
            expected => C_RGB_BLUE,
            message  => "Runtime XGA color-bar geometry mismatch."
        );

        report "tb_vga_pattern_generator_geometry completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
