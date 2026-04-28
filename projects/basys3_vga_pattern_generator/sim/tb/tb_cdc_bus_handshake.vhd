library ieee;
use ieee.std_logic_1164.all;

use std.env.finish;

entity tb_cdc_bus_handshake is
end entity tb_cdc_bus_handshake;

architecture sim of tb_cdc_bus_handshake is

    constant C_WIDTH          : positive := 6;
    constant C_SRC_CLK_PERIOD : time := 10 ns;
    constant C_DST_CLK_PERIOD : time := 15 ns;

    signal src_clk_s          : std_logic := '0';
    signal dst_clk_s          : std_logic := '0';
    signal src_rst_s          : std_logic := '1';
    signal dst_rst_s          : std_logic := '1';
    signal src_valid_s        : std_logic := '0';
    signal src_data_s         : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
    signal src_ready_s        : std_logic;
    signal dst_valid_s        : std_logic;
    signal dst_data_s         : std_logic_vector(C_WIDTH - 1 downto 0);

begin

    src_clk_s <= not src_clk_s after C_SRC_CLK_PERIOD / 2;
    dst_clk_s <= not dst_clk_s after C_DST_CLK_PERIOD / 2;

    dut : entity work.cdc_bus_handshake
        generic map (
            G_WIDTH => C_WIDTH
        )
        port map (
            src_clk_i   => src_clk_s,
            src_rst_i   => src_rst_s,
            src_valid_i => src_valid_s,
            src_data_i  => src_data_s,
            src_ready_o => src_ready_s,
            dst_clk_i   => dst_clk_s,
            dst_rst_i   => dst_rst_s,
            dst_valid_o => dst_valid_s,
            dst_data_o  => dst_data_s
        );

    stimulus : process
    begin
        wait for 100 ns;
        src_rst_s <= '0';
        dst_rst_s <= '0';

        wait until rising_edge(src_clk_s) and src_ready_s = '1';
        src_data_s  <= "100101";
        src_valid_s <= '1';
        wait until rising_edge(src_clk_s);
        src_valid_s <= '0';

        for i in 1 to 20 loop
            wait until rising_edge(dst_clk_s);

            if dst_valid_s = '1' then
                assert dst_data_s = "100101"
                    report "CDC handshake delivered the wrong payload."
                    severity failure;

                report "tb_cdc_bus_handshake completed successfully."
                    severity note;
                finish;
            end if;
        end loop;

        assert false
            report "CDC handshake did not deliver a destination valid pulse."
            severity failure;
    end process;

end architecture sim;
