library ieee;
use ieee.std_logic_1164.all;

entity reset_controller is
    generic (
        G_SYNC_STAGES : positive := 3
    );
    port (
        sys_clk_i          : in  std_logic;
        pixel_clk_i        : in  std_logic;
        btn_reset_i        : in  std_logic;
        pixel_clk_locked_i : in  std_logic;
        clk_wiz_reset_o    : out std_logic;
        sys_rst_o          : out std_logic;
        pixel_rst_o        : out std_logic
    );
end entity reset_controller;

architecture rtl of reset_controller is

    signal btn_meta_s        : std_logic := '1';
    signal btn_sync_s        : std_logic := '1';
    signal sys_rst_pipe_s    : std_logic_vector(G_SYNC_STAGES - 1 downto 0) := (others => '1');
    signal sys_rst_s         : std_logic := '1';
    signal sys_rst_pixel_meta_s : std_logic := '1';
    signal sys_rst_pixel_sync_s : std_logic := '1';
    signal locked_pixel_meta_s  : std_logic := '0';
    signal locked_pixel_sync_s  : std_logic := '0';
    signal pixel_rst_pipe_s  : std_logic_vector(G_SYNC_STAGES - 1 downto 0) := (others => '1');
    signal pixel_rst_s       : std_logic := '1';

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of btn_meta_s       : signal is "TRUE";
    attribute ASYNC_REG of btn_sync_s       : signal is "TRUE";
    attribute ASYNC_REG of sys_rst_pipe_s   : signal is "TRUE";
    attribute ASYNC_REG of sys_rst_pixel_meta_s : signal is "TRUE";
    attribute ASYNC_REG of sys_rst_pixel_sync_s : signal is "TRUE";
    attribute ASYNC_REG of locked_pixel_meta_s  : signal is "TRUE";
    attribute ASYNC_REG of locked_pixel_sync_s  : signal is "TRUE";
    attribute ASYNC_REG of pixel_rst_pipe_s : signal is "TRUE";

begin

    clk_wiz_reset_o <= sys_rst_s;
    sys_rst_o       <= sys_rst_s;
    pixel_rst_o     <= pixel_rst_s;

    p_sys_reset : process(sys_clk_i)
    begin
        if rising_edge(sys_clk_i) then
            btn_meta_s <= btn_reset_i;
            btn_sync_s <= btn_meta_s;

            sys_rst_pipe_s <= sys_rst_pipe_s(G_SYNC_STAGES - 2 downto 0) & btn_sync_s;
            sys_rst_s      <= sys_rst_pipe_s(G_SYNC_STAGES - 1);
        end if;
    end process;

    p_pixel_reset : process(pixel_clk_i)
    begin
        if rising_edge(pixel_clk_i) then
            sys_rst_pixel_meta_s <= sys_rst_s;
            sys_rst_pixel_sync_s <= sys_rst_pixel_meta_s;
            locked_pixel_meta_s  <= pixel_clk_locked_i;
            locked_pixel_sync_s  <= locked_pixel_meta_s;

            if sys_rst_pixel_sync_s = '1' or locked_pixel_sync_s = '0' then
                pixel_rst_pipe_s <= (others => '1');
                pixel_rst_s      <= '1';
            else
                pixel_rst_pipe_s <= pixel_rst_pipe_s(G_SYNC_STAGES - 2 downto 0) & '0';
                pixel_rst_s      <= pixel_rst_pipe_s(G_SYNC_STAGES - 1);
            end if;
        end if;
    end process;

end architecture rtl;
