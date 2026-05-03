library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_timing_pkg.all;
use work.vga_timing_sim_pkg.all;

entity tb_vga_timing_generator_reset is
end entity tb_vga_timing_generator_reset;

architecture sim of tb_vga_timing_generator_reset is

    constant C_MODE             : t_vga_mode := VGA_640X480_60;
    constant C_TIMING           : t_vga_timing := get_vga_timing(C_MODE);
    constant C_H_TOTAL          : natural := get_h_total(C_TIMING);
    constant C_H_ACTIVE_START   : natural := get_h_active_start(C_TIMING);
    constant C_H_ADDR_START     : natural := get_h_addr_start(C_TIMING);
    constant C_V_ACTIVE_START   : natural := get_v_active_start(C_TIMING);
    constant C_V_ADDR_START     : natural := get_v_addr_start(C_TIMING);
    constant C_FIRST_ACTIVE_CYC : natural := (C_V_ACTIVE_START * C_H_TOTAL) + C_H_ACTIVE_START;
    constant C_FIRST_VIDEO_CYC  : natural := (C_V_ADDR_START * C_H_TOTAL) + C_H_ADDR_START;
    constant C_CLK_PERIOD       : time := 10 ns;

    signal pixel_clk_s          : std_logic := '0';
    signal sync_pos_rst_s       : std_logic := '1';
    signal hold_s               : std_logic := '0';

    signal hsync_s              : std_logic;
    signal vsync_s              : std_logic;
    signal active_video_s       : std_logic;
    signal video_on_s           : std_logic;
    signal x_s                  : unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
    signal y_s                  : unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0);
    signal mode_switch_safe_s   : std_logic;
    signal hold_active_s        : std_logic;

    procedure assert_reset_state is
    begin
        assert_std_logic_equal(
            actual   => hsync_s,
            expected => expected_sync_level(false, C_TIMING.h_polarity),
            message  => "Held state hsync mismatch."
        );
        assert_std_logic_equal(
            actual   => vsync_s,
            expected => expected_sync_level(false, C_TIMING.v_polarity),
            message  => "Held state vsync mismatch."
        );
        assert_std_logic_equal(
            actual   => active_video_s,
            expected => '0',
            message  => "active_video_o must be low while held."
        );
        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '0',
            message  => "video_on_o must be low while held."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must be zero while held."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o must be zero while held."
        );
        assert_std_logic_equal(
            actual   => mode_switch_safe_s,
            expected => '0',
            message  => "mode_switch_safe_o must be low while held."
        );
    end procedure;

begin

    pixel_clk_s <= not pixel_clk_s after C_CLK_PERIOD / 2;

    dut : entity work.vga_timing_generator
        port map (
            pixel_clk_i        => pixel_clk_s,
            sync_pos_rst_i     => sync_pos_rst_s,
            mode_i             => C_MODE,
            hold_i             => hold_s,
            hsync_o            => hsync_s,
            vsync_o            => vsync_s,
            active_video_o     => active_video_s,
            video_on_o         => video_on_s,
            x_o                => x_s,
            y_o                => y_s,
            mode_switch_safe_o => mode_switch_safe_s,
            hold_active_o      => hold_active_s
        );

    stimulus : process
        variable cycles_since_release_v : natural := 0;
    begin
        wait until rising_edge(pixel_clk_s);
        wait until rising_edge(pixel_clk_s);

        assert_reset_state;

        sync_pos_rst_s <= '0';
        wait until rising_edge(pixel_clk_s);
        cycles_since_release_v := cycles_since_release_v + 1;

        assert_std_logic_equal(
            actual   => mode_switch_safe_s,
            expected => '1',
            message  => "First non-held cycle must be a mode-switch safe frame origin."
        );

        while active_video_s /= '1' loop
            wait until rising_edge(pixel_clk_s);
            cycles_since_release_v := cycles_since_release_v + 1;
        end loop;

        assert_natural_equal(
            actual   => cycles_since_release_v,
            expected => C_FIRST_ACTIVE_CYC + 1,
            message  => "active_video_o asserted at the wrong cycle after reset release."
        );
        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '0',
            message  => "video_on_o must still be low at the first active-video cycle."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must stay zero before the addressable region starts."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o must stay zero before the addressable region starts."
        );

        while video_on_s /= '1' loop
            wait until rising_edge(pixel_clk_s);
            cycles_since_release_v := cycles_since_release_v + 1;
        end loop;

        assert_natural_equal(
            actual   => cycles_since_release_v,
            expected => C_FIRST_VIDEO_CYC + 1,
            message  => "video_on_o asserted at the wrong cycle after reset release."
        );
        assert_std_logic_equal(
            actual   => active_video_s,
            expected => '1',
            message  => "active_video_o must be high at the first addressable pixel."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must start from zero at the first addressable pixel."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o must start from zero at the first addressable line."
        );

        wait until rising_edge(pixel_clk_s);
        assert_unsigned_equal(
            actual   => x_s,
            expected => 1,
            message  => "x_o must increment on the second addressable pixel."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o must stay on the first addressable line while x_o increments."
        );

        sync_pos_rst_s <= '1';
        wait until rising_edge(pixel_clk_s);
        assert_reset_state;

        wait until rising_edge(pixel_clk_s);
        assert_reset_state;

        hold_s <= '1';
        sync_pos_rst_s <= '0';
        wait until rising_edge(pixel_clk_s);
        assert_reset_state;
        assert_std_logic_equal(
            actual   => hold_active_s,
            expected => '1',
            message  => "hold_active_o must mirror hold_i."
        );

        hold_s <= '0';
        wait until rising_edge(pixel_clk_s);
        assert_std_logic_equal(
            actual   => mode_switch_safe_s,
            expected => '1',
            message  => "Hold release must expose one safe frame-origin cycle."
        );

        sync_pos_rst_s <= '0';
        wait until rising_edge(pixel_clk_s);

        assert_std_logic_equal(
            actual   => hsync_s,
            expected => expected_sync_level(true, C_TIMING.h_polarity),
            message  => "hsync_o mismatch on the first post-reset cycle."
        );
        assert_std_logic_equal(
            actual   => vsync_s,
            expected => expected_sync_level(true, C_TIMING.v_polarity),
            message  => "vsync_o mismatch on the first post-reset cycle."
        );
        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '0',
            message  => "video_on_o must stay low immediately after reset release."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must restart from zero after a mid-frame reset."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o must restart from zero after a mid-frame reset."
        );

        report "tb_vga_timing_generator_reset completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
