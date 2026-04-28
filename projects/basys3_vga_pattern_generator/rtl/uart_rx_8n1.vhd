library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_8n1 is
    generic (
        G_CLK_FREQ_HZ : positive := 100_000_000;
        G_BAUD_RATE   : positive := 9_600
    );
    port (
        clk_i           : in  std_logic;
        rst_i           : in  std_logic;
        rx_i            : in  std_logic;
        data_o          : out std_logic_vector(7 downto 0);
        data_valid_o    : out std_logic;
        framing_error_o : out std_logic
    );
end entity uart_rx_8n1;

architecture rtl of uart_rx_8n1 is

    type t_uart_rx_state is (
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT
    );

    constant C_CLKS_PER_BIT  : positive := (G_CLK_FREQ_HZ + (G_BAUD_RATE / 2)) / G_BAUD_RATE;
    constant C_HALF_BIT_CLKS : positive := C_CLKS_PER_BIT / 2;

    signal state_s           : t_uart_rx_state := IDLE;
    signal clk_count_s       : natural range 0 to C_CLKS_PER_BIT - 1 := 0;
    signal bit_index_s       : natural range 0 to 7 := 0;
    signal shift_reg_s       : std_logic_vector(7 downto 0) := (others => '0');
    signal data_s            : std_logic_vector(7 downto 0) := (others => '0');
    signal data_valid_s      : std_logic := '0';
    signal framing_error_s   : std_logic := '0';
    signal rx_meta_s         : std_logic := '1';
    signal rx_sync_s         : std_logic := '1';

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of rx_meta_s : signal is "TRUE";
    attribute ASYNC_REG of rx_sync_s : signal is "TRUE";

begin

    data_o          <= data_s;
    data_valid_o    <= data_valid_s;
    framing_error_o <= framing_error_s;

    p_rx_sync : process(clk_i)
    begin
        if rising_edge(clk_i) then
            rx_meta_s <= rx_i;
            rx_sync_s <= rx_meta_s;
        end if;
    end process;

    p_uart_rx : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                state_s         <= IDLE;
                clk_count_s     <= 0;
                bit_index_s     <= 0;
                shift_reg_s     <= (others => '0');
                data_s          <= (others => '0');
                data_valid_s    <= '0';
                framing_error_s <= '0';
            else
                data_valid_s    <= '0';
                framing_error_s <= '0';

                case state_s is

                    when IDLE =>
                        clk_count_s <= 0;
                        bit_index_s <= 0;

                        if rx_sync_s = '0' then
                            clk_count_s <= C_HALF_BIT_CLKS - 1;
                            state_s     <= START_BIT;
                        end if;

                    when START_BIT =>
                        if clk_count_s = 0 then
                            if rx_sync_s = '0' then
                                clk_count_s <= C_CLKS_PER_BIT - 1;
                                state_s     <= DATA_BITS;
                            else
                                state_s <= IDLE;
                            end if;
                        else
                            clk_count_s <= clk_count_s - 1;
                        end if;

                    when DATA_BITS =>
                        if clk_count_s = 0 then
                            shift_reg_s(bit_index_s) <= rx_sync_s;
                            clk_count_s              <= C_CLKS_PER_BIT - 1;

                            if bit_index_s = 7 then
                                bit_index_s <= 0;
                                state_s     <= STOP_BIT;
                            else
                                bit_index_s <= bit_index_s + 1;
                            end if;
                        else
                            clk_count_s <= clk_count_s - 1;
                        end if;

                    when STOP_BIT =>
                        if clk_count_s = 0 then
                            if rx_sync_s = '1' then
                                data_s       <= shift_reg_s;
                                data_valid_s <= '1';
                            else
                                framing_error_s <= '1';
                            end if;

                            state_s <= IDLE;
                        else
                            clk_count_s <= clk_count_s - 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

end architecture rtl;
