library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;

entity basys3_vga_top is
    generic (
        G_VGA_MODE : t_vga_mode := VGA_640X480_60
    );
    port (
        clk_100mhz_i : in  std_logic;
        btnc_i       : in  std_logic;
        sw_i         : in  std_logic_vector(C_PATTERN_SEL_WIDTH - 1 downto 0);

        vga_hsync_o  : out std_logic;
        vga_vsync_o  : out std_logic;
        vga_red_o    : out t_rgb_channel;
        vga_green_o  : out t_rgb_channel;
        vga_blue_o   : out t_rgb_channel
    );
end entity basys3_vga_top;

architecture rtl of basys3_vga_top is

    component clk_wiz_pixel_25_2MHz
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

    signal pixel_clk_s       : std_logic;
    signal clk_locked_s      : std_logic;
    signal sync_rst_s        : std_logic;

    signal hsync_s           : std_logic;
    signal vsync_s           : std_logic;
    signal video_on_s        : std_logic;

    signal x_s               : unsigned(C_X_WIDTH - 1 downto 0);
    signal y_s               : unsigned(C_Y_WIDTH - 1 downto 0);

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

    sync_rst_s <= btnc_i or (not clk_locked_s);

    u_clk_wiz_pixel_25_2MHz : clk_wiz_pixel_25_2MHz
        port map (
            clk_out1 => pixel_clk_s,
            reset    => btnc_i,
            locked   => clk_locked_s,
            clk_in1  => clk_100mhz_i
        );

    u_vga_timing_generator : entity work.vga_timing_generator
        generic map (
            G_VGA_MODE => G_VGA_MODE
        )
        port map (
            pixel_clk_i    => pixel_clk_s,
            sync_pos_rst_i => sync_rst_s,
            hsync_o        => hsync_s,
            vsync_o        => vsync_s,
            active_video_o => open,
            video_on_o     => video_on_s,
            x_o            => x_s,
            y_o            => y_s
        );

    u_vga_pattern_generator_top : entity work.vga_pattern_generator
        generic map (
            G_X_WIDTH       => C_X_WIDTH,
            G_Y_WIDTH       => C_Y_WIDTH,
            G_ACTIVE_WIDTH  => C_ACTIVE_WIDTH,
            G_ACTIVE_HEIGHT => C_ACTIVE_HEIGHT
        )
        port map (
            pattern_sel_i => sw_i,
            video_on_i    => video_on_s,
            x_i           => x_s,
            y_i           => y_s,
            red_o         => red_s,
            green_o       => green_s,
            blue_o        => blue_s
        );

    p_vga_output_registers : process(pixel_clk_s)
    begin
        if rising_edge(pixel_clk_s) then
            if sync_rst_s = '1' then
                video_on_reg_s <= '0';

                red_reg_s      <= (others => '0');
                green_reg_s    <= (others => '0');
                blue_reg_s     <= (others => '0');

                hsync_reg_s    <= hsync_s;
                vsync_reg_s    <= vsync_s;
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