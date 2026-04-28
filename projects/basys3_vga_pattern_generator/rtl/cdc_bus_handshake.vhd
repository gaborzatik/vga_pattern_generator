library ieee;
use ieee.std_logic_1164.all;

entity cdc_bus_handshake is
    generic (
        G_WIDTH : positive := 1
    );
    port (
        src_clk_i   : in  std_logic;
        src_rst_i   : in  std_logic;
        src_valid_i : in  std_logic;
        src_data_i  : in  std_logic_vector(G_WIDTH - 1 downto 0);
        src_ready_o : out std_logic;

        dst_clk_i   : in  std_logic;
        dst_rst_i   : in  std_logic;
        dst_valid_o : out std_logic;
        dst_data_o  : out std_logic_vector(G_WIDTH - 1 downto 0)
    );
end entity cdc_bus_handshake;

architecture rtl of cdc_bus_handshake is

    signal src_data_hold_s   : std_logic_vector(G_WIDTH - 1 downto 0) := (others => '0');
    signal src_req_toggle_s  : std_logic := '0';
    signal src_ack_meta_s    : std_logic := '0';
    signal src_ack_sync_s    : std_logic := '0';

    signal dst_req_meta_s    : std_logic := '0';
    signal dst_req_sync_s    : std_logic := '0';
    signal dst_req_seen_s    : std_logic := '0';
    signal dst_ack_toggle_s  : std_logic := '0';
    signal dst_data_s        : std_logic_vector(G_WIDTH - 1 downto 0) := (others => '0');
    signal dst_valid_s       : std_logic := '0';

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of src_ack_meta_s : signal is "TRUE";
    attribute ASYNC_REG of src_ack_sync_s : signal is "TRUE";
    attribute ASYNC_REG of dst_req_meta_s : signal is "TRUE";
    attribute ASYNC_REG of dst_req_sync_s : signal is "TRUE";

begin

    src_ready_o <= '1' when src_req_toggle_s = src_ack_sync_s else '0';
    dst_valid_o <= dst_valid_s;
    dst_data_o  <= dst_data_s;

    p_src_domain : process(src_clk_i)
    begin
        if rising_edge(src_clk_i) then
            if src_rst_i = '1' then
                src_data_hold_s  <= (others => '0');
                src_req_toggle_s <= '0';
                src_ack_meta_s   <= '0';
                src_ack_sync_s   <= '0';
            else
                src_ack_meta_s <= dst_ack_toggle_s;
                src_ack_sync_s <= src_ack_meta_s;

                if src_valid_i = '1' and src_req_toggle_s = src_ack_sync_s then
                    src_data_hold_s  <= src_data_i;
                    src_req_toggle_s <= not src_req_toggle_s;
                end if;
            end if;
        end if;
    end process;

    p_dst_domain : process(dst_clk_i)
    begin
        if rising_edge(dst_clk_i) then
            if dst_rst_i = '1' then
                dst_req_meta_s   <= '0';
                dst_req_sync_s   <= '0';
                dst_req_seen_s   <= '0';
                dst_ack_toggle_s <= '0';
                dst_data_s       <= (others => '0');
                dst_valid_s      <= '0';
            else
                dst_valid_s    <= '0';
                dst_req_meta_s <= src_req_toggle_s;
                dst_req_sync_s <= dst_req_meta_s;

                if dst_req_sync_s /= dst_req_seen_s then
                    dst_data_s       <= src_data_hold_s;
                    dst_valid_s      <= '1';
                    dst_req_seen_s   <= dst_req_sync_s;
                    dst_ack_toggle_s <= dst_req_sync_s;
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
