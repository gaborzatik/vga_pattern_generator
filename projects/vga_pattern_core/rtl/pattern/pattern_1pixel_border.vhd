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
--   Border dimensions come from vga_timing_pkg for G_VGA_MODE and therefore
--   track the addressable video area, not the full active_video_o region.
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
--   G_VGA_MODE selects geometry; video_on_i qualifies the addressable region;
--   x_i/y_i are coordinates in that region; rgb_o is the pattern RGB result.
--
-- Output semantics:
--   Border pixels are green, non-border addressable pixels are blue, and
--   non-addressable pixels are black.
--==============================================================================
entity pattern_1pixel_border is
    generic (
        G_VGA_MODE : t_vga_mode := VGA_640X480_60
    );
    port (
        video_on_i : in  std_logic;
        x_i        : in  unsigned(get_x_coord_width(G_VGA_MODE) - 1 downto 0);
        y_i        : in  unsigned(get_y_coord_width(G_VGA_MODE) - 1 downto 0);
        rgb_o      : out t_rgb_color
    );
end entity pattern_1pixel_border;

architecture rtl of pattern_1pixel_border is
    -- Timing-derived geometry fixes the right and bottom border locations for
    -- the selected VGA mode during elaboration.
    constant C_TIMING        : t_vga_timing := get_vga_timing(G_VGA_MODE);
    constant C_ACTIVE_WIDTH  : natural := C_TIMING.h_addr_video;
    constant C_ACTIVE_HEIGHT : natural := C_TIMING.v_addr_video;

    -- Edge helper functions isolate the four boundary tests so review can focus
    -- on the addressable extents used for border detection.
    function is_left_border_pixel(
        x_coord : unsigned
    ) return boolean is
    begin
        return x_coord = to_unsigned(0, x_coord'length);
    end function is_left_border_pixel;

    function is_right_border_pixel(
        x_coord : unsigned
    ) return boolean is
    begin
        return x_coord = to_unsigned(C_ACTIVE_WIDTH - 1, x_coord'length);
    end function is_right_border_pixel;

    function is_top_border_pixel(
        y_coord : unsigned
    ) return boolean is
    begin
        return y_coord = to_unsigned(0, y_coord'length);
    end function is_top_border_pixel;

    function is_bottom_border_pixel(
        y_coord : unsigned
    ) return boolean is
    begin
        return y_coord = to_unsigned(C_ACTIVE_HEIGHT - 1, y_coord'length);
    end function is_bottom_border_pixel;

    -- Combines all addressable-area boundary checks for a single pixel sample.
    function is_border_pixel(
        x_coord : unsigned;
        y_coord : unsigned
    ) return boolean is
    begin
        return is_left_border_pixel(x_coord) or
               is_right_border_pixel(x_coord) or
               is_top_border_pixel(y_coord) or
               is_bottom_border_pixel(y_coord);
    end function is_border_pixel;
begin

    -- Combinational RGB selection for the border pattern. video_on_i gates the
    -- entire pattern so inactive addressable samples return black.
    process(video_on_i, x_i, y_i)
    begin
        if video_on_i = '1' then
            if is_border_pixel(x_i, y_i) then
                rgb_o <= C_RGB_GREEN;
            else
                rgb_o <= C_RGB_BLUE;
            end if;
        else
            rgb_o <= C_RGB_BLACK;
        end if;
    end process;
end architecture rtl;
