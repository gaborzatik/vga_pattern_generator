library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;
use work.vga_pattern_sim_pkg.all;

entity tb_basys3_vga_top_smoke is
end entity tb_basys3_vga_top_smoke;

architecture sim of tb_basys3_vga_top_smoke is

    constant C_MODE            : t_vga_mode := XGA_1024X768_60;
    constant C_TIMING          : t_vga_timing := get_vga_timing(C_MODE);
    constant C_H_TOTAL         : natural := get_h_total(C_TIMING);
    constant C_V_ADDR_START    : natural := get_v_addr_start(C_TIMING);
    constant C_H_ADDR_START    : natural := get_h_addr_start(C_TIMING);
    constant C_FIRST_VIDEO_CYC : natural := (C_V_ADDR_START * C_H_TOTAL) + C_H_ADDR_START + 16;
    constant C_CLK_PERIOD      : time := 10 ns;

    signal clk_100mhz_s        : std_logic := '0';
    signal btnc_s              : std_logic := '1';
    signal sw_s                : std_logic_vector(C_PATTERN_SEL_WIDTH - 1 downto 0) := pattern_select_from_mode(WHITE);

    signal vga_hsync_s         : std_logic;
    signal vga_vsync_s         : std_logic;
    signal vga_red_s           : t_rgb_channel;
    signal vga_green_s         : t_rgb_channel;
    signal vga_blue_s          : t_rgb_channel;

begin

    clk_100mhz_s <= not clk_100mhz_s after C_CLK_PERIOD / 2;

    dut : entity work.basys3_vga_top
        generic map (
            G_VGA_MODE => C_MODE
        )
        port map (
            clk_100mhz_i => clk_100mhz_s,
            btnc_i       => btnc_s,
            sw_i         => sw_s,
            vga_hsync_o  => vga_hsync_s,
            vga_vsync_o  => vga_vsync_s,
            vga_red_o    => vga_red_s,
            vga_green_o  => vga_green_s,
            vga_blue_o   => vga_blue_s
        );

    stimulus : process
        variable initial_hsync_v     : std_logic;
        variable initial_vsync_v     : std_logic;
        variable seen_hsync_toggle_v : boolean := false;
        variable seen_vsync_toggle_v : boolean := false;
    begin
        wait until rising_edge(clk_100mhz_s);
        wait until rising_edge(clk_100mhz_s);

        assert_rgb_equal(
            actual_red   => vga_red_s,
            actual_green => vga_green_s,
            actual_blue  => vga_blue_s,
            expected     => C_RGB_BLACK,
            message      => "Wrapper outputs must be blank during reset."
        );

        initial_hsync_v := vga_hsync_s;
        initial_vsync_v := vga_vsync_s;

        btnc_s <= '0';

        for i in 1 to 10000 loop
            wait until rising_edge(clk_100mhz_s);

            if vga_hsync_s /= initial_hsync_v then
                seen_hsync_toggle_v := true;
            end if;

            if vga_vsync_s /= initial_vsync_v then
                seen_vsync_toggle_v := true;
            end if;

            exit when seen_hsync_toggle_v and seen_vsync_toggle_v;
        end loop;

        assert seen_hsync_toggle_v
            report "Wrapper smoke test did not observe hsync activity after reset release."
            severity failure;
        assert seen_vsync_toggle_v
            report "Wrapper smoke test did not observe vsync activity after reset release."
            severity failure;

        for i in 1 to C_FIRST_VIDEO_CYC loop
            wait until rising_edge(clk_100mhz_s);
        end loop;

        assert_rgb_equal(
            actual_red   => vga_red_s,
            actual_green => vga_green_s,
            actual_blue  => vga_blue_s,
            expected     => C_RGB_WHITE,
            message      => "Wrapper did not produce WHITE output for the initial selector."
        );

        sw_s <= pattern_select_from_mode(RED);
        wait until rising_edge(clk_100mhz_s);
        wait until rising_edge(clk_100mhz_s);

        assert_rgb_equal(
            actual_red   => vga_red_s,
            actual_green => vga_green_s,
            actual_blue  => vga_blue_s,
            expected     => C_RGB_RED,
            message      => "Wrapper did not propagate a selector change to RED."
        );

        sw_s <= pattern_select_from_mode(BLUE);
        wait until rising_edge(clk_100mhz_s);
        wait until rising_edge(clk_100mhz_s);

        assert_rgb_equal(
            actual_red   => vga_red_s,
            actual_green => vga_green_s,
            actual_blue  => vga_blue_s,
            expected     => C_RGB_BLUE,
            message      => "Wrapper did not propagate a selector change to BLUE."
        );

        report "tb_basys3_vga_top_smoke completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
