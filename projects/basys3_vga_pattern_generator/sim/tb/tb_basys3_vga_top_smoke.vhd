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
    constant C_UART_BIT_PERIOD : time := 104170 ns;

    signal clk_100mhz_s        : std_logic := '0';
    signal btnc_s              : std_logic := '1';
    signal uart_rx_s           : std_logic := '1';

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
            uart_rx_i    => uart_rx_s,
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

        procedure send_uart_byte(
            signal rx_line : out std_logic;
            constant data  : in  std_logic_vector(7 downto 0)
        ) is
        begin
            rx_line <= '0';
            wait for C_UART_BIT_PERIOD;

            for bit_idx in 0 to 7 loop
                rx_line <= data(bit_idx);
                wait for C_UART_BIT_PERIOD;
            end loop;

            rx_line <= '1';
            wait for C_UART_BIT_PERIOD;
        end procedure;

        procedure wait_for_rgb(
            constant expected : in t_rgb_color;
            constant message  : in string
        ) is
        begin
            for i in 1 to C_H_TOTAL * get_v_total(C_TIMING) loop
                wait until rising_edge(clk_100mhz_s);

                if (vga_red_s = expected.red) and
                   (vga_green_s = expected.green) and
                   (vga_blue_s = expected.blue) then
                    return;
                end if;
            end loop;

            assert_rgb_equal(
                actual_red   => vga_red_s,
                actual_green => vga_green_s,
                actual_blue  => vga_blue_s,
                expected     => expected,
                message      => message
            );
        end procedure;
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
        wait until rising_edge(clk_100mhz_s);

        send_uart_byte(
            rx_line => uart_rx_s,
            data    => "00" & pattern_select_from_mode(WHITE)
        );

        for i in 1 to (C_H_TOTAL * get_v_total(C_TIMING)) + C_H_TOTAL loop
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

        send_uart_byte(
            rx_line => uart_rx_s,
            data    => "00" & pattern_select_from_mode(RED)
        );

        wait_for_rgb(
            expected => C_RGB_RED,
            message  => "Wrapper did not propagate a selector change to RED."
        );

        send_uart_byte(
            rx_line => uart_rx_s,
            data    => "00" & pattern_select_from_mode(BLUE)
        );

        wait_for_rgb(
            expected => C_RGB_BLUE,
            message  => "Wrapper did not propagate a selector change to BLUE."
        );

        report "tb_basys3_vga_top_smoke completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
