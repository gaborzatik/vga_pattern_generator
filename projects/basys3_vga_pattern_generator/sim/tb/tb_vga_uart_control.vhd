library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_pattern_common_pkg.all;

entity tb_vga_uart_control is
end entity tb_vga_uart_control;

architecture sim of tb_vga_uart_control is

    constant C_CLK_PERIOD      : time := 10 ns;
    constant C_UART_BIT_PERIOD : time := 104170 ns;

    signal clk_s              : std_logic := '0';
    signal rst_s              : std_logic := '1';
    signal uart_rx_s          : std_logic := '1';
    signal pattern_sel_s      : t_pattern_sel_slv;
    signal pattern_sel_valid_s : std_logic;
    signal clock_sel_s        : std_logic_vector(5 downto 0);
    signal clock_sel_valid_s  : std_logic;
    signal uart_frame_error_s : std_logic;

begin

    clk_s <= not clk_s after C_CLK_PERIOD / 2;

    dut : entity work.vga_uart_control
        generic map (
            G_CLK_FREQ_HZ => 100_000_000,
            G_BAUD_RATE   => 9_600
        )
        port map (
            clk_i              => clk_s,
            rst_i              => rst_s,
            uart_rx_i          => uart_rx_s,
            pattern_sel_o      => pattern_sel_s,
            pattern_sel_valid_o => pattern_sel_valid_s,
            clock_sel_o        => clock_sel_s,
            clock_sel_valid_o  => clock_sel_valid_s,
            uart_frame_error_o => uart_frame_error_s
        );

    stimulus : process
        variable seen_pattern_valid_v : boolean := false;
        variable seen_clock_valid_v : boolean := false;

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
            wait for C_UART_BIT_PERIOD / 2;
        end procedure;
    begin
        wait until rising_edge(clk_s);
        wait until rising_edge(clk_s);

        assert pattern_sel_s = pattern_select_from_mode(BLACK)
            report "UART control default pattern selector is not BLACK."
            severity failure;

        rst_s <= '0';
        wait until rising_edge(clk_s);

        send_uart_byte(
            rx_line => uart_rx_s,
            data    => "00" & pattern_select_from_mode(RED)
        );

        for i in 1 to 20000 loop
            wait until rising_edge(clk_s);

            if pattern_sel_valid_s = '1' then
                seen_pattern_valid_v := true;
                exit;
            end if;
        end loop;

        assert seen_pattern_valid_v
            report "UART control did not pulse pattern_sel_valid_o for VGA_MODE_SELECT."
            severity failure;
        assert pattern_sel_s = pattern_select_from_mode(RED)
            report "UART control did not decode VGA_MODE_SELECT RED."
            severity failure;
        wait until rising_edge(clk_s);
        assert pattern_sel_valid_s = '0'
            report "UART control pattern valid pulse did not return low."
            severity failure;
        assert uart_frame_error_s = '0'
            report "UART control reported an unexpected frame error."
            severity failure;

        send_uart_byte(
            rx_line => uart_rx_s,
            data    => "01" & "000010"
        );

        for i in 1 to 20000 loop
            wait until rising_edge(clk_s);

            if clock_sel_valid_s = '1' then
                seen_clock_valid_v := true;
                exit;
            end if;
        end loop;

        assert seen_clock_valid_v
            report "UART control did not pulse clock_sel_valid_o for VGA_CLOCK_SELECT."
            severity failure;
        assert clock_sel_s = "000010"
            report "UART control did not decode VGA_CLOCK_SELECT value 2."
            severity failure;

        report "tb_vga_uart_control completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
