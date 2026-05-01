--==============================================================================
-- File        : tb_vga_pattern_generator_selectors.vhd
-- Project     : vga_pattern_core
-- Unit        : tb_vga_pattern_generator_selectors
--
-- Description :
--   Verifies selector-to-pattern mapping for implemented modes and representative
--   fallback behavior for unimplemented enum literals.
--
-- Project role:
--   Simulation testbench for the vga_pattern_generator selector path.
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
--   This testbench samples selected coordinates rather than scanning a full frame.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;
use work.vga_pattern_gray_pkg.all;
use work.vga_pattern_sim_pkg.all;

--==============================================================================
-- Entity: tb_vga_pattern_generator_selectors
--
-- Purpose:
--   Top-level simulation wrapper with no ports. The pass condition is reaching
--   std.env.finish after all selector checks complete.
--
-- Verification scope:
--   Confirms selector encoding through pattern_select_from_mode for implemented
--   patterns, and documents current black fallback behavior for selected
--   unimplemented modes.
--==============================================================================
entity tb_vga_pattern_generator_selectors is
end entity tb_vga_pattern_generator_selectors;

architecture sim of tb_vga_pattern_generator_selectors is

    -- Test geometry matches the default VGA mode used by the DUT generics.
    constant C_MODE          : t_vga_mode := VGA_640X480_60;
    constant C_X_WIDTH       : natural := get_x_coord_width(C_MODE);
    constant C_Y_WIDTH       : natural := get_y_coord_width(C_MODE);
    constant C_ACTIVE_WIDTH  : natural := get_vga_timing(C_MODE).h_addr_video;
    constant C_ACTIVE_HEIGHT : natural := get_vga_timing(C_MODE).v_addr_video;

    signal pattern_sel_s     : t_pattern_sel_slv := (others => '0');
    signal video_on_s        : std_logic := '0';
    signal x_s               : unsigned(C_X_WIDTH - 1 downto 0) := (others => '0');
    signal y_s               : unsigned(C_Y_WIDTH - 1 downto 0) := (others => '0');
    signal red_s             : t_rgb_channel;
    signal green_s           : t_rgb_channel;
    signal blue_s            : t_rgb_channel;

    -- Drives a raw selector value plus coordinate/video inputs into the DUT and
    -- checks the selected RGB sample after combinational settling.
    procedure drive_and_expect(
        signal pattern_sel  : out t_pattern_sel_slv;
        signal video_on     : out std_logic;
        signal x_value      : out unsigned;
        signal y_value      : out unsigned;
        signal actual_red   : in  t_rgb_channel;
        signal actual_green : in  t_rgb_channel;
        signal actual_blue  : in  t_rgb_channel;
        constant selector : t_pattern_sel_slv;
        constant x_coord  : natural;
        constant y_coord  : natural;
        constant video_on_value : std_logic;
        constant expected : t_rgb_color;
        constant message  : string
    ) is
    begin
        pattern_sel <= selector;
        video_on    <= video_on_value;
        x_value     <= to_unsigned(x_coord, x_value'length);
        y_value     <= to_unsigned(y_coord, y_value'length);
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

    -- Device under test: the full pattern generator is used so selector decoding,
    -- pattern production, and the enum-indexed RGB mux are checked together.
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

    -- Sequential selector samples. Representative unimplemented enum literals
    -- are expected to use the top-level aggregate's black default.
    stimulus : process
    begin
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(BLACK),
            x_coord  => 0,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_BLACK,
            message  => "BLACK selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(WHITE),
            x_coord  => 12,
            y_coord  => 7,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "WHITE selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(RED),
            x_coord  => 12,
            y_coord  => 7,
            video_on_value => '1',
            expected => C_RGB_RED,
            message  => "RED selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(GREEN),
            x_coord  => 12,
            y_coord  => 7,
            video_on_value => '1',
            expected => C_RGB_GREEN,
            message  => "GREEN selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(BLUE),
            x_coord  => 12,
            y_coord  => 7,
            video_on_value => '1',
            expected => C_RGB_BLUE,
            message  => "BLUE selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(GRAY_10),
            x_coord  => 12,
            y_coord  => 7,
            video_on_value => '1',
            expected => C_RGB_GRAY_1_15,
            message  => "GRAY_10 selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(GRAY_50),
            x_coord  => 12,
            y_coord  => 7,
            video_on_value => '1',
            expected => C_RGB_GRAY_7_15,
            message  => "GRAY_50 selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(GRAY_80),
            x_coord  => 12,
            y_coord  => 7,
            video_on_value => '1',
            expected => C_RGB_GRAY_11_15,
            message  => "GRAY_80 selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(COLOR_BARS),
            x_coord  => 0,
            y_coord  => 20,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "COLOR_BARS selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(GRAYSCALE_RAMP),
            x_coord  => C_ACTIVE_WIDTH - 1,
            y_coord  => 20,
            video_on_value => '1',
            expected => C_RGB_GRAY_15_15,
            message  => "GRAYSCALE_RAMP selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(CHECKER_1PX),
            x_coord  => 1,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_1PX selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(CHECKER_2PX),
            x_coord  => 2,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_2PX selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(CHECKER_4PX),
            x_coord  => 4,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_4PX selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(CHECKER_8PX),
            x_coord  => 8,
            y_coord  => 0,
            video_on_value => '1',
            expected => C_RGB_WHITE,
            message  => "CHECKER_8PX selector mismatch."
        );
        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(BORDER_1PX),
            x_coord  => 0,
            y_coord  => 32,
            video_on_value => '1',
            expected => C_RGB_GREEN,
            message  => "BORDER_1PX selector mismatch."
        );

        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(PLUGE_BLACK),
            x_coord  => 10,
            y_coord  => 10,
            video_on_value => '1',
            expected => C_RGB_BLACK,
            message  => "Default fallback mismatch for PLUGE_BLACK."
        );

        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(CENTER_CROSS),
            x_coord  => 10,
            y_coord  => 10,
            video_on_value => '1',
            expected => C_RGB_BLACK,
            message  => "Default fallback mismatch for CENTER_CROSS."
        );

        drive_and_expect(
            pattern_sel  => pattern_sel_s,
            video_on     => video_on_s,
            x_value      => x_s,
            y_value      => y_s,
            actual_red   => red_s,
            actual_green => green_s,
            actual_blue  => blue_s,
            selector => pattern_select_from_mode(FRAME_MARKER),
            x_coord  => 10,
            y_coord  => 10,
            video_on_value => '1',
            expected => C_RGB_BLACK,
            message  => "Default fallback mismatch for FRAME_MARKER."
        );

        report "tb_vga_pattern_generator_selectors completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
