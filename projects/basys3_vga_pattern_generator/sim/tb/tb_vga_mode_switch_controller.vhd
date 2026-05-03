library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_timing_pkg.all;

entity tb_vga_mode_switch_controller is
end entity tb_vga_mode_switch_controller;

architecture sim of tb_vga_mode_switch_controller is

    constant C_SYS_CLK_PERIOD   : time := 10 ns;
    constant C_PIXEL_CLK_PERIOD : time := 14 ns;

    signal sys_clk_s            : std_logic := '0';
    signal pixel_clk_s          : std_logic := '0';
    signal sys_rst_s            : std_logic := '1';
    signal pixel_rst_s          : std_logic := '1';

    signal mode_cmd_valid_s     : std_logic := '0';
    signal mode_cmd_payload_s   : std_logic_vector(5 downto 0) := (others => '0');
    signal clock_locked_s       : std_logic := '1';
    signal mode_switch_safe_s   : std_logic := '0';

    signal busy_s               : std_logic;
    signal pixel_hold_s         : std_logic;
    signal requested_mode_s     : t_vga_mode;
    signal current_mode_s       : t_vga_mode;
    signal active_mode_s        : t_vga_mode;
    signal mux_low_sel_s        : std_logic;
    signal mux_xga_sel_s        : std_logic;

    procedure send_mode_command(
        signal clk     : in  std_logic;
        signal valid_o : out std_logic;
        signal data_o  : out std_logic_vector(5 downto 0);
        constant data  : in  std_logic_vector(5 downto 0)
    ) is
    begin
        wait until rising_edge(clk);
        data_o  <= data;
        valid_o <= '1';
        wait until rising_edge(clk);
        valid_o <= '0';
    end procedure;

    procedure wait_sys_cycles(
        signal clk      : in std_logic;
        constant cycles : in natural
    ) is
    begin
        for i in 1 to cycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

    procedure pulse_safe(
        signal clk    : in  std_logic;
        signal safe_o : out std_logic
    ) is
    begin
        wait until rising_edge(clk);
        safe_o <= '1';
        wait until rising_edge(clk);
        safe_o <= '0';
    end procedure;

begin

    sys_clk_s   <= not sys_clk_s after C_SYS_CLK_PERIOD / 2;
    pixel_clk_s <= not pixel_clk_s after C_PIXEL_CLK_PERIOD / 2;

    dut : entity work.vga_mode_switch_controller
        generic map (
            G_CLOCK_MUX_SETTLE_CYCLES => 4
        )
        port map (
            sys_clk_i          => sys_clk_s,
            sys_rst_i          => sys_rst_s,
            pixel_clk_i        => pixel_clk_s,
            pixel_rst_i        => pixel_rst_s,
            mode_cmd_valid_i   => mode_cmd_valid_s,
            mode_cmd_payload_i => mode_cmd_payload_s,
            clock_locked_i     => clock_locked_s,
            mode_switch_safe_i => mode_switch_safe_s,
            busy_o             => busy_s,
            pixel_hold_o       => pixel_hold_s,
            requested_mode_o   => requested_mode_s,
            current_mode_o     => current_mode_s,
            active_mode_o      => active_mode_s,
            mux_low_sel_o      => mux_low_sel_s,
            mux_xga_sel_o      => mux_xga_sel_s
        );

    stimulus : process
    begin
        wait_sys_cycles(sys_clk_s, 3);
        assert busy_s = '0'
            report "Controller must reset idle."
            severity failure;
        assert requested_mode_s = XGA_1024X768_60 and
               current_mode_s = XGA_1024X768_60 and
               active_mode_s = XGA_1024X768_60
            report "Controller modes must reset to XGA."
            severity failure;
        assert mux_xga_sel_s = '1'
            report "Controller must select the XGA clock after reset."
            severity failure;

        sys_rst_s   <= '0';
        pixel_rst_s <= '0';
        wait_sys_cycles(sys_clk_s, 8);

        assert busy_s = '0'
            report "Controller must be idle after reset release."
            severity failure;

        send_mode_command(sys_clk_s, mode_cmd_valid_s, mode_cmd_payload_s, "111111");
        wait_sys_cycles(sys_clk_s, 4);
        assert busy_s = '0'
            report "Invalid mode payload must be ignored."
            severity failure;

        send_mode_command(sys_clk_s, mode_cmd_valid_s, mode_cmd_payload_s, "000010");
        wait_sys_cycles(sys_clk_s, 4);
        assert busy_s = '0'
            report "Idle same-mode command must be ignored."
            severity failure;

        send_mode_command(sys_clk_s, mode_cmd_valid_s, mode_cmd_payload_s, "000000");
        wait_sys_cycles(sys_clk_s, 2);
        assert busy_s = '1'
            report "Valid different-mode command must start a switch."
            severity failure;
        assert requested_mode_s = VGA_640X480_60
            report "Requested mode must latch before request_toggle."
            severity failure;

        send_mode_command(sys_clk_s, mode_cmd_valid_s, mode_cmd_payload_s, "000001");
        wait_sys_cycles(sys_clk_s, 2);
        assert requested_mode_s = VGA_640X480_60
            report "Busy mode command must not overwrite requested_mode."
            severity failure;

        wait_sys_cycles(sys_clk_s, 8);
        assert pixel_hold_s = '0'
            report "Pixel pipeline must keep running while waiting for frame-safe."
            severity failure;

        pulse_safe(pixel_clk_s, mode_switch_safe_s);

        for i in 1 to 80 loop
            wait until rising_edge(sys_clk_s);
            exit when busy_s = '0';
        end loop;

        assert busy_s = '0'
            report "Controller did not complete the mode switch."
            severity failure;
        assert current_mode_s = VGA_640X480_60
            report "Current mode did not update to VGA."
            severity failure;

        for i in 1 to 16 loop
            wait until rising_edge(pixel_clk_s);
            exit when active_mode_s = VGA_640X480_60;
        end loop;

        assert active_mode_s = VGA_640X480_60
            report "Active mode did not update to VGA after release."
            severity failure;
        assert mux_xga_sel_s = '0' and mux_low_sel_s = '0'
            report "Clock mux selects do not match VGA."
            severity failure;
        assert pixel_hold_s = '0'
            report "Pixel hold must release after the switch completes."
            severity failure;

        report "tb_vga_mode_switch_controller completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
