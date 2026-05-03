library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;

entity vga_mode_switch_controller is
    generic (
        G_CLOCK_MUX_SETTLE_CYCLES : natural := 256
    );
    port (
        sys_clk_i          : in  std_logic;
        sys_rst_i          : in  std_logic;
        pixel_clk_i        : in  std_logic;
        pixel_rst_i        : in  std_logic;

        mode_cmd_valid_i   : in  std_logic;
        mode_cmd_payload_i : in  std_logic_vector(5 downto 0);
        clock_locked_i     : in  std_logic;
        mode_switch_safe_i : in  std_logic;

        busy_o             : out std_logic;
        pixel_hold_o       : out std_logic;

        requested_mode_o   : out t_vga_mode;
        current_mode_o     : out t_vga_mode;
        active_mode_o      : out t_vga_mode;

        mux_low_sel_o      : out std_logic;
        mux_xga_sel_o      : out std_logic
    );
end entity vga_mode_switch_controller;

architecture rtl of vga_mode_switch_controller is

    type t_sys_state is (
        SYS_IDLE,
        SYS_WAIT_SAFE_ACK,
        SYS_SWITCH_CLOCK,
        SYS_WAIT_CLOCK_STABLE,
        SYS_RELEASE_PIXEL
    );

    type t_pixel_state is (
        PIXEL_RUN,
        PIXEL_WAIT_FRAME_SAFE,
        PIXEL_HOLD_UNTIL_RELEASE
    );

    signal sys_state_s       : t_sys_state := SYS_IDLE;
    signal pixel_state_s     : t_pixel_state := PIXEL_RUN;

    signal requested_mode_s  : t_vga_mode := XGA_1024X768_60;
    signal current_mode_s    : t_vga_mode := XGA_1024X768_60;
    signal active_mode_s     : t_vga_mode := XGA_1024X768_60;

    signal request_toggle_s  : std_logic := '0';
    signal release_toggle_s  : std_logic := '0';
    signal safe_ack_toggle_s : std_logic := '0';

    signal safe_ack_meta_s   : std_logic := '0';
    signal safe_ack_sync_s   : std_logic := '0';
    signal safe_ack_seen_s   : std_logic := '0';

    signal request_meta_s    : std_logic := '0';
    signal request_sync_s    : std_logic := '0';
    signal request_seen_s    : std_logic := '0';
    signal release_meta_s    : std_logic := '0';
    signal release_sync_s    : std_logic := '0';
    signal release_seen_s    : std_logic := '0';

    signal settle_counter_s  : natural := 0;
    signal pixel_hold_s      : std_logic := '1';

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of safe_ack_meta_s : signal is "TRUE";
    attribute ASYNC_REG of safe_ack_sync_s : signal is "TRUE";
    attribute ASYNC_REG of request_meta_s  : signal is "TRUE";
    attribute ASYNC_REG of request_sync_s  : signal is "TRUE";
    attribute ASYNC_REG of release_meta_s  : signal is "TRUE";
    attribute ASYNC_REG of release_sync_s  : signal is "TRUE";

    function f_payload_valid(
        payload : std_logic_vector(5 downto 0)
    ) return boolean is
    begin
        return (payload = "000000") or
               (payload = "000001") or
               (payload = "000010");
    end function;

    function f_payload_to_mode(
        payload : std_logic_vector(5 downto 0)
    ) return t_vga_mode is
    begin
        case payload is
            when "000000" =>
                return VGA_640X480_60;
            when "000001" =>
                return SVGA_800X600_60;
            when others =>
                return XGA_1024X768_60;
        end case;
    end function;

    function f_mux_low_sel(
        mode : t_vga_mode
    ) return std_logic is
    begin
        if mode = SVGA_800X600_60 then
            return '1';
        else
            return '0';
        end if;
    end function;

    function f_mux_xga_sel(
        mode : t_vga_mode
    ) return std_logic is
    begin
        if mode = XGA_1024X768_60 then
            return '1';
        else
            return '0';
        end if;
    end function;

begin

    busy_o           <= '1' when sys_state_s /= SYS_IDLE else '0';
    pixel_hold_o     <= pixel_hold_s;
    requested_mode_o <= requested_mode_s;
    current_mode_o   <= current_mode_s;
    active_mode_o    <= active_mode_s;
    mux_low_sel_o    <= f_mux_low_sel(current_mode_s);
    mux_xga_sel_o    <= f_mux_xga_sel(current_mode_s);

    p_sys_domain : process(sys_clk_i)
        variable next_mode_v : t_vga_mode;
    begin
        if rising_edge(sys_clk_i) then
            if sys_rst_i = '1' then
                sys_state_s       <= SYS_IDLE;
                requested_mode_s  <= XGA_1024X768_60;
                current_mode_s    <= XGA_1024X768_60;
                request_toggle_s  <= '0';
                release_toggle_s  <= '0';
                safe_ack_meta_s   <= '0';
                safe_ack_sync_s   <= '0';
                safe_ack_seen_s   <= '0';
                settle_counter_s  <= 0;
            else
                safe_ack_meta_s <= safe_ack_toggle_s;
                safe_ack_sync_s <= safe_ack_meta_s;

                case sys_state_s is
                    when SYS_IDLE =>
                        if mode_cmd_valid_i = '1' and f_payload_valid(mode_cmd_payload_i) then
                            next_mode_v := f_payload_to_mode(mode_cmd_payload_i);

                            if next_mode_v /= current_mode_s then
                                requested_mode_s <= next_mode_v;
                                request_toggle_s <= not request_toggle_s;
                                sys_state_s      <= SYS_WAIT_SAFE_ACK;
                            end if;
                        end if;

                    when SYS_WAIT_SAFE_ACK =>
                        if safe_ack_sync_s /= safe_ack_seen_s then
                            safe_ack_seen_s <= safe_ack_sync_s;
                            sys_state_s     <= SYS_SWITCH_CLOCK;
                        end if;

                    when SYS_SWITCH_CLOCK =>
                        current_mode_s   <= requested_mode_s;
                        settle_counter_s <= G_CLOCK_MUX_SETTLE_CYCLES;
                        sys_state_s      <= SYS_WAIT_CLOCK_STABLE;

                    when SYS_WAIT_CLOCK_STABLE =>
                        if settle_counter_s /= 0 then
                            settle_counter_s <= settle_counter_s - 1;
                        elsif clock_locked_i = '1' then
                            sys_state_s <= SYS_RELEASE_PIXEL;
                        end if;

                    when SYS_RELEASE_PIXEL =>
                        release_toggle_s <= not release_toggle_s;
                        sys_state_s      <= SYS_IDLE;
                end case;
            end if;
        end if;
    end process;

    p_pixel_domain : process(pixel_clk_i)
    begin
        if rising_edge(pixel_clk_i) then
            if pixel_rst_i = '1' then
                pixel_state_s     <= PIXEL_RUN;
                active_mode_s     <= XGA_1024X768_60;
                request_meta_s    <= '0';
                request_sync_s    <= '0';
                request_seen_s    <= '0';
                release_meta_s    <= '0';
                release_sync_s    <= '0';
                release_seen_s    <= '0';
                safe_ack_toggle_s <= '0';
                pixel_hold_s      <= '1';
            else
                request_meta_s <= request_toggle_s;
                request_sync_s <= request_meta_s;
                release_meta_s <= release_toggle_s;
                release_sync_s <= release_meta_s;

                case pixel_state_s is
                    when PIXEL_RUN =>
                        pixel_hold_s <= '0';

                        if request_sync_s /= request_seen_s then
                            pixel_state_s <= PIXEL_WAIT_FRAME_SAFE;
                        end if;

                    when PIXEL_WAIT_FRAME_SAFE =>
                        if mode_switch_safe_i = '1' then
                            pixel_hold_s      <= '1';
                            request_seen_s    <= request_sync_s;
                            safe_ack_toggle_s <= not safe_ack_toggle_s;
                            pixel_state_s     <= PIXEL_HOLD_UNTIL_RELEASE;
                        end if;

                    when PIXEL_HOLD_UNTIL_RELEASE =>
                        pixel_hold_s <= '1';

                        if release_sync_s /= release_seen_s then
                            active_mode_s  <= requested_mode_s;
                            release_seen_s <= release_sync_s;
                            pixel_hold_s   <= '0';
                            pixel_state_s  <= PIXEL_RUN;
                        end if;
                end case;
            end if;
        end if;
    end process;

end architecture rtl;
