--==============================================================================
-- File        : pattern_1pixel_border.vhd
-- Project     : vga_pattern_core
-- Unit        : pattern_1pixel_border
--
-- Description :
--   Generates a one-pixel border around the addressable pattern area and fills
--   the interior with a contrasting color.
--
-- Project role:
--   Coordinate-dependent pattern source selected by vga_pattern_generator.
--
-- Design level:
--   RTL pattern block.
--
-- Clock/reset:
--   No clock or reset; combinational logic driven by video_on_i, x_i, and y_i.
--
-- Synthesis:
--   Synthesizable combinational RTL.
--
-- Review notes:
--   Border dimensions come from vga_timing_pkg for runtime mode_i and
--   therefore track the addressable video area, not the full active_video_o
--   region.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;
use work.vga_pattern_common_pkg.all;

--==============================================================================
-- Entity: pattern_1pixel_border
--
-- Purpose:
--   Marks the first and last addressable rows/columns as border pixels.
--
-- Interface groups:
--   mode_i selects geometry; video_on_i qualifies the addressable region;
--   x_i/y_i are coordinates in that region; rgb_o is the pattern RGB result.
--
-- Output semantics:
--   Border pixels are green, non-border addressable pixels are blue, and
--   non-addressable pixels are black.
--==============================================================================
entity pattern_1pixel_border is
    port (
        video_on_i : in  std_logic;
        mode_i     : in  t_vga_mode;
        x_i        : in  unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
        y_i        : in  unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0);
        rgb_o      : out t_rgb_color
    );
end entity pattern_1pixel_border;

architecture rtl of pattern_1pixel_border is
    function is_border_pixel(
        mode    : t_vga_mode;
        x_coord : unsigned;
        y_coord : unsigned
    ) return boolean is
        variable v_timing : t_vga_timing;
    begin
        v_timing := get_vga_timing(mode);
        return (x_coord = to_unsigned(0, x_coord'length)) or
               (x_coord = to_unsigned(v_timing.h_addr_video - 1, x_coord'length)) or
               (y_coord = to_unsigned(0, y_coord'length)) or
               (y_coord = to_unsigned(v_timing.v_addr_video - 1, y_coord'length));
    end function is_border_pixel;
begin

    -- Combinational RGB selection for the border pattern. video_on_i gates the
    -- entire pattern so inactive addressable samples return black.
    process(video_on_i, mode_i, x_i, y_i)
    begin
        if video_on_i = '1' then
            if is_border_pixel(mode_i, x_i, y_i) then
                rgb_o <= C_RGB_GREEN;
            else
                rgb_o <= C_RGB_BLUE;
            end if;
        else
            rgb_o <= C_RGB_BLACK;
        end if;
    end process;
end architecture rtl;
