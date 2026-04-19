----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.04.2026 17:25:18
-- Design Name: 
-- Module Name: pattern_color_solid_black - Behavioral
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

entity pattern_solid_black is
    port (
        rgb_o      : out work.vga_pattern_common_pkg.t_rgb_color
    );
end pattern_solid_black;

architecture Behavioral of pattern_solid_black is
begin
    rgb_o <= work.vga_pattern_common_pkg.C_RGB_BLACK;
end Behavioral;