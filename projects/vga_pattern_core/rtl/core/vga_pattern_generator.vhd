library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_pattern_common_pkg.all;
use work.vga_timing_pkg.all;

entity vga_pattern_generator is
    generic (
        G_VGA_MODE      : t_vga_mode := VGA_640X480_60;
        G_X_WIDTH       : natural := 10;
        G_Y_WIDTH       : natural := 10;
        G_ACTIVE_WIDTH  : natural := 640;
        G_ACTIVE_HEIGHT : natural := 480
    );
    port (
        pattern_sel_i : in  t_pattern_sel_slv;
        video_on_i    : in  std_logic;
        x_i           : in  unsigned(G_X_WIDTH - 1 downto 0);
        y_i           : in  unsigned(G_Y_WIDTH - 1 downto 0);

        red_o         : out t_rgb_channel;
        green_o       : out t_rgb_channel;
        blue_o        : out t_rgb_channel
    );
end entity vga_pattern_generator;

architecture rtl of vga_pattern_generator is

    signal pattern_mode_s          : t_pattern_mode;

    signal solid_black_rgb_s        : t_rgb_color;
    signal solid_white_rgb_s        : t_rgb_color;
    signal solid_red_rgb_s          : t_rgb_color;
    signal solid_green_rgb_s        : t_rgb_color;
    signal solid_blue_rgb_s         : t_rgb_color;
    signal solid_gray_10_rgb_s      : t_rgb_color;
    signal solid_gray_50_rgb_s      : t_rgb_color;
    signal solid_gray_80_rgb_s      : t_rgb_color;
    signal color_bars_rgb_s         : t_rgb_color;
    signal grayscale_ramp_rgb_s     : t_rgb_color;
    signal checker_1px_rgb_s        : t_rgb_color;
    signal checker_2px_rgb_s        : t_rgb_color;
    signal checker_4px_rgb_s        : t_rgb_color;
    signal checker_8px_rgb_s        : t_rgb_color;
    signal border_1px_rgb_s         : t_rgb_color;

    signal pattern_outputs_s       : t_pattern_rgb_array;
    signal selected_rgb_s          : t_rgb_color;

begin

    pattern_mode_s <= pattern_mode_from_select(pattern_sel_i);

    u_pattern_solid_black : entity work.pattern_solid_black
        port map (
            rgb_o => solid_black_rgb_s
        );

    u_pattern_solid_white : entity work.pattern_solid_white
        port map (
            video_on_i => video_on_i,
            rgb_o => solid_white_rgb_s
        );

    u_pattern_solid_red : entity work.pattern_solid_red
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_red_rgb_s
        );
        
    u_pattern_solid_green : entity work.pattern_solid_green
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_green_rgb_s
        );
      
    u_pattern_solid_blue : entity work.pattern_solid_blue
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_blue_rgb_s
        );
        
    u_pattern_solid_gray_10 : entity work.pattern_solid_gray_10
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_gray_10_rgb_s
        );
        
    u_pattern_solid_gray_50 : entity work.pattern_solid_gray_50
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_gray_50_rgb_s
        );
        
    u_pattern_solid_gray_80 : entity work.pattern_solid_gray_80
        port map (
            video_on_i => video_on_i,
            rgb_o      => solid_gray_80_rgb_s
        );

    u_pattern_seven_bars : entity work.pattern_seven_bars
        generic map (
            G_VGA_MODE => G_VGA_MODE
        )
        port map (
            video_on_i => video_on_i,
            x_i        => x_i,
            rgb_o      => color_bars_rgb_s
        );

    u_pattern_grayscale_ramp : entity work.pattern_grayscale_ramp
        generic map (
            G_VGA_MODE => G_VGA_MODE
        )
        port map (
            video_on_i => video_on_i,
            x_i        => x_i,
            rgb_o      => grayscale_ramp_rgb_s
        );
        
    u_pattern_checker_1px : entity work.pattern_checker
        port map (
            video_on_i => video_on_i,
            x_bit_i    => x_i(0),
            y_bit_i    => y_i(0),
            rgb_o      => checker_1px_rgb_s
        );
        
    u_pattern_checker_2px : entity work.pattern_checker
        port map (
            video_on_i => video_on_i,
            x_bit_i    => x_i(1),
            y_bit_i    => y_i(1),
            rgb_o      => checker_2px_rgb_s
        );
        
    u_pattern_checker_4px : entity work.pattern_checker
        port map (
            video_on_i => video_on_i,
            x_bit_i    => x_i(2),
            y_bit_i    => y_i(2),
            rgb_o      => checker_4px_rgb_s
        );
        
    u_pattern_checker_8px : entity work.pattern_checker
        port map (
            video_on_i => video_on_i,
            x_bit_i    => x_i(3),
            y_bit_i    => y_i(3),
            rgb_o      => checker_8px_rgb_s
        );

    u_pattern_1pixel_border : entity work.pattern_1pixel_border
        generic map (
            G_VGA_MODE => G_VGA_MODE
        )
        port map (
            video_on_i => video_on_i,
            x_i        => x_i,
            y_i        => y_i,
            rgb_o      => border_1px_rgb_s
        );

    pattern_outputs_s <= (
        BLACK               => solid_black_rgb_s,
        WHITE               => solid_white_rgb_s,
        RED                 => solid_red_rgb_s,
        GREEN               => solid_green_rgb_s,
        BLUE                => solid_blue_rgb_s,
        GRAY_10             => solid_gray_10_rgb_s,
        GRAY_50             => solid_gray_50_rgb_s,
        GRAY_80             => solid_gray_80_rgb_s,
        COLOR_BARS          => color_bars_rgb_s,
        GRAYSCALE_RAMP      => grayscale_ramp_rgb_s,
        CHECKER_1PX         => checker_1px_rgb_s,
        CHECKER_2PX         => checker_2px_rgb_s,
        CHECKER_4PX         => checker_4px_rgb_s,
        CHECKER_8PX         => checker_8px_rgb_s,
        BORDER_1PX          => border_1px_rgb_s,
        others      => C_RGB_BLACK
    );

    selected_rgb_s <= pattern_outputs_s(pattern_mode_s);

    red_o   <= selected_rgb_s.red;
    green_o <= selected_rgb_s.green;
    blue_o  <= selected_rgb_s.blue;

end architecture rtl;
