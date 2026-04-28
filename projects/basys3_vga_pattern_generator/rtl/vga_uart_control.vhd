library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_pattern_common_pkg.all;

entity vga_uart_control is
    generic (
        G_CLK_FREQ_HZ : positive := 100_000_000;
        G_BAUD_RATE   : positive := 9_600
    );
    port (
        clk_i              : in  std_logic;
        rst_i              : in  std_logic;
        uart_rx_i          : in  std_logic;
        pattern_sel_o      : out t_pattern_sel_slv;
        pattern_sel_valid_o : out std_logic;
        clock_sel_o        : out std_logic_vector(5 downto 0);
        clock_sel_valid_o  : out std_logic;
        uart_frame_error_o : out std_logic
    );
end entity vga_uart_control;

architecture rtl of vga_uart_control is

    constant C_UART_OP_VGA_MODE_SELECT  : std_logic_vector(1 downto 0) := "00";
    constant C_UART_OP_VGA_CLOCK_SELECT : std_logic_vector(1 downto 0) := "01";
    constant C_DEFAULT_PATTERN_SEL      : t_pattern_sel_slv := pattern_select_from_mode(BLACK);

    signal rx_data_s                    : std_logic_vector(7 downto 0);
    signal rx_data_valid_s              : std_logic;
    signal pattern_sel_s                : t_pattern_sel_slv := C_DEFAULT_PATTERN_SEL;
    signal pattern_sel_valid_s          : std_logic := '0';
    signal clock_sel_s                  : std_logic_vector(5 downto 0) := (others => '0');
    signal clock_sel_valid_s            : std_logic := '0';

begin

    assert C_PATTERN_SEL_WIDTH <= 6
        report "UART VGA mode payload only carries 6 selector bits."
        severity failure;

    pattern_sel_o     <= pattern_sel_s;
    pattern_sel_valid_o <= pattern_sel_valid_s;
    clock_sel_o       <= clock_sel_s;
    clock_sel_valid_o <= clock_sel_valid_s;

    u_uart_rx : entity work.uart_rx_8n1
        generic map (
            G_CLK_FREQ_HZ => G_CLK_FREQ_HZ,
            G_BAUD_RATE   => G_BAUD_RATE
        )
        port map (
            clk_i           => clk_i,
            rst_i           => rst_i,
            rx_i            => uart_rx_i,
            data_o          => rx_data_s,
            data_valid_o    => rx_data_valid_s,
            framing_error_o => uart_frame_error_o
        );

    p_decode : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                pattern_sel_s       <= C_DEFAULT_PATTERN_SEL;
                pattern_sel_valid_s <= '0';
                clock_sel_s         <= (others => '0');
                clock_sel_valid_s   <= '0';
            else
                pattern_sel_valid_s <= '0';
                clock_sel_valid_s   <= '0';

                if rx_data_valid_s = '1' then
                    case rx_data_s(7 downto 6) is

                        when C_UART_OP_VGA_MODE_SELECT =>
                            pattern_sel_s       <= rx_data_s(C_PATTERN_SEL_WIDTH - 1 downto 0);
                            pattern_sel_valid_s <= '1';

                        when C_UART_OP_VGA_CLOCK_SELECT =>
                            clock_sel_s       <= rx_data_s(5 downto 0);
                            clock_sel_valid_s <= '1';

                        when others =>
                            null;

                    end case;
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
