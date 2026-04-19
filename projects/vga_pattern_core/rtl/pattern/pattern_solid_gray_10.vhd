----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.04.2026 21:21:38
-- Design Name: 
-- Module Name: pattern_solid_gray_10 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity pattern_solid_gray_10 is
    port (
        video_on_i : in  std_logic;
        rgb_o      : out work.vga_pattern_common_pkg.t_rgb_color
    );
end pattern_solid_gray_10;

architecture Behavioral of pattern_solid_gray_10 is

begin
    rgb_o <= work.vga_pattern_gray_pkg.C_RGB_GRAY_1_15  when video_on_i = '1' 
                                                        else work.vga_pattern_gray_pkg.C_RGB_GRAY_0_15;
end Behavioral;
