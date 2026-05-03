--==============================================================================
-- File        : pattern_grayscale_ramp.vhd
-- Project     : vga_pattern_core
-- Unit        : pattern_grayscale_ramp
--
-- Description :
--   Generates a horizontal 16-step grayscale ramp across the addressable video
--   width.
--
-- Project role:
--   Coordinate-dependent pattern source selected by vga_pattern_generator.
--
-- Design level:
--   RTL pattern block.
--
-- Clock/reset:
--   No clock or reset; combinational logic driven by video_on_i and x_i.
--
-- Synthesis:
--   Synthesizable combinational RTL.
--
-- Review notes:
--   The ramp uses runtime mode_i timing geometry, so x_i is expected to be
--   aligned with the same mode's addressable coordinate range.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;
use work.vga_pattern_gray_pkg.all;

--==============================================================================
-- Entity: pattern_grayscale_ramp
--
-- Purpose:
--   Converts the horizontal pixel coordinate into one of the package-defined
--   grayscale levels while video_on_i is asserted.
--
-- Interface groups:
--   mode_i selects horizontal active width; video_on_i qualifies the
--   addressable pattern area; x_i is the current horizontal coordinate; rgb_o is
--   the combinational grayscale result.
--
-- Output semantics:
--   Inactive samples return the black grayscale level.
--==============================================================================
entity pattern_grayscale_ramp is
    port (
        video_on_i : in  std_logic;
        mode_i     : in  t_vga_mode;
        x_i        : in  unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
        rgb_o      : out t_rgb_color
    );
end entity pattern_grayscale_ramp;

architecture rtl of pattern_grayscale_ramp is
    function f_gray_index_from_step(
        constant x_value : natural;
        constant step    : natural
    ) return natural is
    begin
        if x_value < step then
            return 0;
        elsif x_value < step * 2 then
            return 1;
        elsif x_value < step * 3 then
            return 2;
        elsif x_value < step * 4 then
            return 3;
        elsif x_value < step * 5 then
            return 4;
        elsif x_value < step * 6 then
            return 5;
        elsif x_value < step * 7 then
            return 6;
        elsif x_value < step * 8 then
            return 7;
        elsif x_value < step * 9 then
            return 8;
        elsif x_value < step * 10 then
            return 9;
        elsif x_value < step * 11 then
            return 10;
        elsif x_value < step * 12 then
            return 11;
        elsif x_value < step * 13 then
            return 12;
        elsif x_value < step * 14 then
            return 13;
        elsif x_value < step * 15 then
            return 14;
        else
            return 15;
        end if;
    end function;

    function f_gray_index(
        constant mode    : t_vga_mode;
        constant x_value : natural
    ) return natural is
    begin
        case mode is
            when VGA_640X480_60 =>
                return f_gray_index_from_step(x_value, 40);
            when SVGA_800X600_60 =>
                return f_gray_index_from_step(x_value, 50);
            when XGA_1024X768_60 =>
                return f_gray_index_from_step(x_value, 64);
        end case;
    end function;
begin

    -- Combinational ramp lookup. All supported active widths divide evenly into
    -- 16 bins, so fixed thresholds avoid a runtime divider.
    process(video_on_i, mode_i, x_i)
        variable v_gray_index : natural range 0 to 15;
    begin
        if video_on_i = '1' then
            v_gray_index := f_gray_index(mode_i, to_integer(x_i));

            case v_gray_index is
                when 0 =>
                    rgb_o <= C_RGB_GRAY_0_15;
                when 1 =>
                    rgb_o <= C_RGB_GRAY_1_15;
                when 2 =>
                    rgb_o <= C_RGB_GRAY_2_15;
                when 3 =>
                    rgb_o <= C_RGB_GRAY_3_15;
                when 4 =>
                    rgb_o <= C_RGB_GRAY_4_15;
                when 5 =>
                    rgb_o <= C_RGB_GRAY_5_15;
                when 6 =>
                    rgb_o <= C_RGB_GRAY_6_15;
                when 7 =>
                    rgb_o <= C_RGB_GRAY_7_15;
                when 8 =>
                    rgb_o <= C_RGB_GRAY_8_15;
                when 9 =>
                    rgb_o <= C_RGB_GRAY_9_15;
                when 10 =>
                    rgb_o <= C_RGB_GRAY_10_15;
                when 11 =>
                    rgb_o <= C_RGB_GRAY_11_15;
                when 12 =>
                    rgb_o <= C_RGB_GRAY_12_15;
                when 13 =>
                    rgb_o <= C_RGB_GRAY_13_15;
                when 14 =>
                    rgb_o <= C_RGB_GRAY_14_15;
                when others =>
                    rgb_o <= C_RGB_GRAY_15_15;
            end case;
        else
            rgb_o <= C_RGB_GRAY_0_15;
        end if;
    end process;

end architecture rtl;
