library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;

entity basys3_vga_top is
    generic (
        G_VGA_MODE : t_vga_mode := XGA_1024X768_60
    );
    port (
        clk_100mhz_i : in  std_logic;
        btnc_i       : in  std_logic;
        uart_rx_i    : in  std_logic;

        vga_hsync_o  : out std_logic;
        vga_vsync_o  : out std_logic;
        vga_red_o    : out t_rgb_channel;
        vga_green_o  : out t_rgb_channel;
        vga_blue_o   : out t_rgb_channel
    );
end entity basys3_vga_top;

architecture rtl of basys3_vga_top is

    -- Current pixel clock: 65 MHz for the default XGA_1024X768_60 mode.
    -- TODO: replace the single clock with runtime clock selection for the
    -- currently supported VGA modes.
    component clk_wiz_pixel
        port (
            clk_out1 : out std_logic;
            reset    : in  std_logic;
            locked   : out std_logic;
            clk_in1  : in  std_logic
        );
    end component;

    constant C_TIMING        : t_vga_timing := get_vga_timing(G_VGA_MODE);
    constant C_X_WIDTH       : natural := get_x_coord_width(G_VGA_MODE);
    constant C_Y_WIDTH       : natural := get_y_coord_width(G_VGA_MODE);
    constant C_ACTIVE_WIDTH  : natural := C_TIMING.h_addr_video;
    constant C_ACTIVE_HEIGHT : natural := C_TIMING.v_addr_video;

    signal clk_100mhz_ibuf_s : std_logic;
    signal sys_clk_s         : std_logic;
    signal pixel_clk_s       : std_logic;
    signal clk_locked_s      : std_logic;
    signal clk_wiz_reset_s   : std_logic;
    signal sys_rst_s         : std_logic;
    signal pixel_rst_s       : std_logic;

    signal hsync_s           : std_logic;
    signal vsync_s           : std_logic;
    signal video_on_s        : std_logic;

    signal vga_mode_s        : t_vga_mode := G_VGA_MODE;
    signal x_s               : unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
    signal y_s               : unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0);

    signal pattern_sel_ctrl_s : t_pattern_sel_slv;
    signal pattern_sel_valid_ctrl_s : std_logic;
    signal pattern_sel_cdc_ready_s : std_logic;
    signal pattern_sel_transfer_valid_s : std_logic := '0';
    signal pattern_sel_transfer_data_s : t_pattern_sel_slv := pattern_select_from_mode(BLACK);
    signal pattern_sel_pending_valid_s : std_logic := '0';
    signal pattern_sel_pending_s : t_pattern_sel_slv := pattern_select_from_mode(BLACK);
    signal pattern_sel_valid_pixel_s : std_logic;
    signal pattern_sel_cdc_s  : t_pattern_sel_slv;
    signal pattern_sel_s      : t_pattern_sel_slv := pattern_select_from_mode(BLACK);

    signal red_s             : t_rgb_channel;
    signal green_s           : t_rgb_channel;
    signal blue_s            : t_rgb_channel;

    signal hsync_reg_s       : std_logic := '1';
    signal vsync_reg_s       : std_logic := '1';
    signal video_on_reg_s    : std_logic := '0';

    signal red_reg_s         : t_rgb_channel := (others => '0');
    signal green_reg_s       : t_rgb_channel := (others => '0');
    signal blue_reg_s        : t_rgb_channel := (others => '0');

begin

    u_clk_100mhz_ibuf : IBUF
        port map (
            I => clk_100mhz_i,
            O => clk_100mhz_ibuf_s
        );

    u_sys_clk_bufg : BUFG
        port map (
            I => clk_100mhz_ibuf_s,
            O => sys_clk_s
        );

    u_reset_controller : entity work.reset_controller
        port map (
            sys_clk_i          => sys_clk_s,
            pixel_clk_i        => pixel_clk_s,
            btn_reset_i        => btnc_i,
            pixel_clk_locked_i => clk_locked_s,
            clk_wiz_reset_o    => clk_wiz_reset_s,
            sys_rst_o          => sys_rst_s,
            pixel_rst_o        => pixel_rst_s
        );

    u_clk_wiz_pixel : clk_wiz_pixel
        port map (
            clk_out1 => pixel_clk_s,
            reset    => clk_wiz_reset_s,
            locked   => clk_locked_s,
            clk_in1  => sys_clk_s
        );

    u_vga_uart_control : entity work.vga_uart_control
        generic map (
            G_CLK_FREQ_HZ => 100_000_000,
            G_BAUD_RATE   => 9_600
        )
        port map (
            clk_i              => sys_clk_s,
            rst_i              => sys_rst_s,
            uart_rx_i          => uart_rx_i,
            pattern_sel_o      => pattern_sel_ctrl_s,
            pattern_sel_valid_o => pattern_sel_valid_ctrl_s,
            clock_sel_o        => open,
            clock_sel_valid_o  => open,
            uart_frame_error_o => open
        );

    p_pattern_sel_pending : process(sys_clk_s)
        variable next_pending_valid_v : std_logic;
        variable next_pending_v       : t_pattern_sel_slv;
    begin
        if rising_edge(sys_clk_s) then
            if sys_rst_s = '1' then
                pattern_sel_transfer_valid_s <= '0';
                pattern_sel_transfer_data_s  <= pattern_select_from_mode(BLACK);
                pattern_sel_pending_valid_s  <= '0';
                pattern_sel_pending_s        <= pattern_select_from_mode(BLACK);
            else
                pattern_sel_transfer_valid_s <= '0';

                next_pending_valid_v := pattern_sel_pending_valid_s;
                next_pending_v       := pattern_sel_pending_s;

                if pattern_sel_valid_ctrl_s = '1' then
                    next_pending_valid_v := '1';
                    next_pending_v       := pattern_sel_ctrl_s;
                end if;

                if next_pending_valid_v = '1' and pattern_sel_cdc_ready_s = '1' then
                    pattern_sel_transfer_valid_s <= '1';
                    pattern_sel_transfer_data_s  <= next_pending_v;
                    pattern_sel_pending_valid_s  <= '0';
                    pattern_sel_pending_s        <= next_pending_v;
                else
                    pattern_sel_pending_valid_s <= next_pending_valid_v;
                    pattern_sel_pending_s       <= next_pending_v;
                end if;
            end if;
        end if;
    end process;

    u_pattern_sel_cdc : entity work.cdc_bus_handshake
        generic map (
            G_WIDTH => C_PATTERN_SEL_WIDTH
        )
        port map (
            src_clk_i   => sys_clk_s,
            src_rst_i   => sys_rst_s,
            src_valid_i => pattern_sel_transfer_valid_s,
            src_data_i  => pattern_sel_transfer_data_s,
            src_ready_o => pattern_sel_cdc_ready_s,
            dst_clk_i   => pixel_clk_s,
            dst_rst_i   => pixel_rst_s,
            dst_valid_o => pattern_sel_valid_pixel_s,
            dst_data_o  => pattern_sel_cdc_s
        );

    p_pattern_sel_register : process(pixel_clk_s)
    begin
        if rising_edge(pixel_clk_s) then
            if pixel_rst_s = '1' then
                pattern_sel_s      <= pattern_select_from_mode(BLACK);
            elsif pattern_sel_valid_pixel_s = '1' then
                pattern_sel_s      <= pattern_sel_cdc_s;
            end if;
        end if;
    end process;

    u_vga_timing_generator : entity work.vga_timing_generator
        port map (
            pixel_clk_i    => pixel_clk_s,
            sync_pos_rst_i => pixel_rst_s,
            vga_mode_i     => vga_mode_s,
            hsync_o        => hsync_s,
            vsync_o        => vsync_s,
            active_video_o => open,
            video_on_o     => video_on_s,
            x_o            => x_s,
            y_o            => y_s
        );

    u_vga_pattern_generator_top : entity work.vga_pattern_generator
        generic map (
            G_VGA_MODE      => G_VGA_MODE,
            G_X_WIDTH       => C_X_WIDTH,
            G_Y_WIDTH       => C_Y_WIDTH,
            G_ACTIVE_WIDTH  => C_ACTIVE_WIDTH,
            G_ACTIVE_HEIGHT => C_ACTIVE_HEIGHT
        )
        port map (
            pattern_sel_i => pattern_sel_s,
            video_on_i    => video_on_s,
            x_i           => x_s(C_X_WIDTH - 1 downto 0),
            y_i           => y_s(C_Y_WIDTH - 1 downto 0),
            red_o         => red_s,
            green_o       => green_s,
            blue_o        => blue_s
        );

    p_vga_output_registers : process(pixel_clk_s)
    begin
        if rising_edge(pixel_clk_s) then
            if pixel_rst_s = '1' then
                video_on_reg_s <= '0';

                red_reg_s      <= (others => '0');
                green_reg_s    <= (others => '0');
                blue_reg_s     <= (others => '0');

                if C_TIMING.h_polarity = ACTIVE_LOW then
                    hsync_reg_s <= '1';
                else
                    hsync_reg_s <= '0';
                end if;

                if C_TIMING.v_polarity = ACTIVE_LOW then
                    vsync_reg_s <= '1';
                else
                    vsync_reg_s <= '0';
                end if;
                
            else
                video_on_reg_s <= video_on_s;

                red_reg_s      <= red_s;
                green_reg_s    <= green_s;
                blue_reg_s     <= blue_s;

                hsync_reg_s    <= hsync_s;
                vsync_reg_s    <= vsync_s;
            end if;
        end if;
    end process;

    vga_red_o   <= red_reg_s   when video_on_reg_s = '1' else (others => '0');
    vga_green_o <= green_reg_s when video_on_reg_s = '1' else (others => '0');
    vga_blue_o  <= blue_reg_s  when video_on_reg_s = '1' else (others => '0');

    vga_hsync_o <= hsync_reg_s;
    vga_vsync_o <= vsync_reg_s;

end architecture rtl;
