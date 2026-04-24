library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_wiz_pixel is
    port (
        clk_out1 : out std_logic;
        reset    : in  std_logic;
        locked   : out std_logic;
        clk_in1  : in  std_logic
    );
end entity clk_wiz_pixel;

architecture sim of clk_wiz_pixel is
    signal lock_counter_s : natural range 0 to 3 := 0;
    signal locked_s       : std_logic := '0';
begin

    clk_out1 <= clk_in1;
    locked   <= locked_s;

    process(clk_in1, reset)
    begin
        if reset = '1' then
            lock_counter_s <= 0;
            locked_s       <= '0';
        elsif rising_edge(clk_in1) then
            if lock_counter_s = 3 then
                locked_s <= '1';
            else
                lock_counter_s <= lock_counter_s + 1;
                locked_s       <= '0';
            end if;
        end if;
    end process;

end architecture sim;
