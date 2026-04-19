----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.04.2026 17:09:25
-- Design Name: 
-- Module Name: vga_pattern_gray_pkg - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.vga_pattern_common_pkg.all;

package vga_pattern_gray_pkg is

    -- Gray constants
    constant C_RGB_GRAY_0_15 : t_rgb_color := (
        red   => (others => '0'),
        green => (others => '0'),
        blue  => (others => '0')
    );
    
    constant C_RGB_GRAY_1_15 : t_rgb_color := (
        red   => "0001",
        green => "0001",
        blue  => "0001"
    );
    
    constant C_RGB_GRAY_2_15 : t_rgb_color := (
        red   => "0010",
        green => "0010",
        blue  => "0010"
    );
    
    constant C_RGB_GRAY_3_15 : t_rgb_color := (
        red   => "0011",
        green => "0011",
        blue  => "0011"
    );
    
    constant C_RGB_GRAY_4_15 : t_rgb_color := (
        red   => "0100",
        green => "0100",
        blue  => "0100"
    );
    
    constant C_RGB_GRAY_5_15 : t_rgb_color := (
        red   => "0101",
        green => "0101",
        blue  => "0101"
    );
    
    constant C_RGB_GRAY_6_15 : t_rgb_color := (
        red   => "0110",
        green => "0110",
        blue  => "0110"
    );
    
    constant C_RGB_GRAY_7_15 : t_rgb_color := (
        red   => "0111",
        green => "0111",
        blue  => "0111"
    );
    
    constant C_RGB_GRAY_8_15 : t_rgb_color := (
        red   => "1000",
        green => "1000",
        blue  => "1000"
    );
    
    constant C_RGB_GRAY_9_15 : t_rgb_color := (
        red   => "1001",
        green => "1001",
        blue  => "1001"
    );
    
    constant C_RGB_GRAY_10_15 : t_rgb_color := (
        red   => "1010",
        green => "1010",
        blue  => "1010"
    );
    
    constant C_RGB_GRAY_11_15 : t_rgb_color := (
        red   => "1011",
        green => "1011",
        blue  => "1011"
    );
    
    constant C_RGB_GRAY_12_15 : t_rgb_color := (
        red   => "1100",
        green => "1100",
        blue  => "1100"
    );
    
    constant C_RGB_GRAY_13_15 : t_rgb_color := (
        red   => "1101",
        green => "1101",
        blue  => "1101"
    );
    
    constant C_RGB_GRAY_14_15 : t_rgb_color := (
        red   => "1110",
        green => "1110",
        blue  => "1110"
    );    
    
    constant C_RGB_GRAY_15_15 : t_rgb_color := (
        red   => (others => '1'),
        green => (others => '1'),
        blue  => (others => '1')
    );
    
    
end package vga_pattern_gray_pkg;

package body vga_pattern_gray_pkg is
end package body vga_pattern_gray_pkg;