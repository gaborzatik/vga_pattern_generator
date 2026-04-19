library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pattern_grayscale_ramp is
    generic (
        G_X_WIDTH      : natural := 10
    );
    port (
        video_on_i : in  std_logic;
        x_i        : in  unsigned(G_X_WIDTH - 1 downto 0);
        rgb_o      : out work.vga_pattern_common_pkg.t_rgb_color
    );
end entity pattern_grayscale_ramp;

architecture rtl of pattern_grayscale_ramp is


begin
-- it is prepared for 640x480
 process(video_on_i, x_i)
    begin
        if video_on_i = '1' then
            case (to_integer(x_i)) is
                when 0 to 39 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_0_15;
                when 40 to 79 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_1_15;
                when 80 to 119 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_2_15;
                when 120 to 159 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_3_15;
                when 160 to 199 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_4_15;
                when 200 to 239 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_5_15;
                when 240 to 279 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_6_15;
                when 280 to 319 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_7_15;
                when 320 to 359 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_8_15;
                when 360 to 399 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_9_15;
                when 400 to 439 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_10_15;
                when 440 to 479 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_11_15;
                when 480 to 519 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_12_15;
                when 520 to 559 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_13_15;
                when 560 to 599 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_14_15;
                when 600 to 639 => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_15_15;
                
                when others => 
                    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_0_15;
                end case;
        else
            rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_0_15;
        end if;
    end process;
end architecture rtl;