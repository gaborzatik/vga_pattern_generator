library ieee;
use ieee.std_logic_1164.all;

package vga_timing_pkg is

    type t_sync_polarity is (
        ACTIVE_LOW,
        ACTIVE_HIGH
    );

    type t_vga_mode is (
        VGA_640X480_60,
        SVGA_800X600_60,
        XGA_1024X768_60
    );

    type t_vga_timing is record
        -- VESA 3.5 order:
        -- Sync -> Back Porch -> Left/Top Border -> Addressable Video
        --      -> Right/Bottom Border -> Front Porch

        h_sync          : natural;
        h_back_porch    : natural;
        h_left_border   : natural;
        h_addr_video    : natural;
        h_right_border  : natural;
        h_front_porch   : natural;

        v_sync          : natural;
        v_back_porch    : natural;
        v_top_border    : natural;
        v_addr_video    : natural;
        v_bottom_border : natural;
        v_front_porch   : natural;

        h_polarity      : t_sync_polarity;
        v_polarity      : t_sync_polarity;

        pixel_clock_hz  : natural;
    end record;

    function get_vga_timing(
        mode : t_vga_mode
    ) return t_vga_timing;

    function get_h_total(
        timing : t_vga_timing
    ) return natural;

    function get_v_total(
        timing : t_vga_timing
    ) return natural;

    function get_h_active_start(
        timing : t_vga_timing
    ) return natural;

    function get_h_active_end(
        timing : t_vga_timing
    ) return natural;

    function get_v_active_start(
        timing : t_vga_timing
    ) return natural;

    function get_v_active_end(
        timing : t_vga_timing
    ) return natural;

    function get_h_addr_start(
        timing : t_vga_timing
    ) return natural;

    function get_h_addr_end(
        timing : t_vga_timing
    ) return natural;

    function get_v_addr_start(
        timing : t_vga_timing
    ) return natural;

    function get_v_addr_end(
        timing : t_vga_timing
    ) return natural;

    function f_sync_output_level(
        sync_active : boolean;
        polarity    : t_sync_polarity
    ) return std_logic;
    
    function get_x_coord_width(
    mode : t_vga_mode
    ) return natural;

    function get_y_coord_width(
    mode : t_vga_mode
    ) return natural;

end package;


package body vga_timing_pkg is

    function get_vga_timing(
        mode : t_vga_mode
    ) return t_vga_timing is
        variable timing_v : t_vga_timing;
    begin
        case mode is

            when VGA_640X480_60 =>
                -- VESA DMT 640x480 @ 60 Hz
                timing_v.h_sync          := 96;
                timing_v.h_back_porch    := 40;
                timing_v.h_left_border   := 8;
                timing_v.h_addr_video    := 640;
                timing_v.h_right_border  := 8;
                timing_v.h_front_porch   := 8;

                timing_v.v_sync          := 2;
                timing_v.v_back_porch    := 25;
                timing_v.v_top_border    := 8;
                timing_v.v_addr_video    := 480;
                timing_v.v_bottom_border := 8;
                timing_v.v_front_porch   := 2;

                timing_v.h_polarity      := ACTIVE_LOW;
                timing_v.v_polarity      := ACTIVE_LOW;

                timing_v.pixel_clock_hz  := 25_175_000;

            when SVGA_800X600_60 =>
                -- VESA DMT 800x600 @ 60 Hz
                timing_v.h_sync          := 128;
                timing_v.h_back_porch    := 88;
                timing_v.h_left_border   := 0;
                timing_v.h_addr_video    := 800;
                timing_v.h_right_border  := 0;
                timing_v.h_front_porch   := 40;

                timing_v.v_sync          := 4;
                timing_v.v_back_porch    := 23;
                timing_v.v_top_border    := 0;
                timing_v.v_addr_video    := 600;
                timing_v.v_bottom_border := 0;
                timing_v.v_front_porch   := 1;

                timing_v.h_polarity      := ACTIVE_HIGH;
                timing_v.v_polarity      := ACTIVE_HIGH;

                timing_v.pixel_clock_hz  := 40_000_000;

            when XGA_1024X768_60 =>
                -- VESA DMT 1024x768 @ 60 Hz
                timing_v.h_sync          := 136;
                timing_v.h_back_porch    := 160;
                timing_v.h_left_border   := 0;
                timing_v.h_addr_video    := 1024;
                timing_v.h_right_border  := 0;
                timing_v.h_front_porch   := 24;

                timing_v.v_sync          := 6;
                timing_v.v_back_porch    := 29;
                timing_v.v_top_border    := 0;
                timing_v.v_addr_video    := 768;
                timing_v.v_bottom_border := 0;
                timing_v.v_front_porch   := 3;

                timing_v.h_polarity      := ACTIVE_LOW;
                timing_v.v_polarity      := ACTIVE_LOW;

                timing_v.pixel_clock_hz  := 65_000_000;

        end case;

        return timing_v;
    end function;


    function get_h_total(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.h_sync +
               timing.h_back_porch +
               timing.h_left_border +
               timing.h_addr_video +
               timing.h_right_border +
               timing.h_front_porch;
    end function;


    function get_v_total(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.v_sync +
               timing.v_back_porch +
               timing.v_top_border +
               timing.v_addr_video +
               timing.v_bottom_border +
               timing.v_front_porch;
    end function;


    function get_h_active_start(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.h_sync +
               timing.h_back_porch;
    end function;


    function get_h_active_end(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.h_sync +
               timing.h_back_porch +
               timing.h_left_border +
               timing.h_addr_video +
               timing.h_right_border;
    end function;


    function get_v_active_start(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.v_sync +
               timing.v_back_porch;
    end function;


    function get_v_active_end(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.v_sync +
               timing.v_back_porch +
               timing.v_top_border +
               timing.v_addr_video +
               timing.v_bottom_border;
    end function;


    function get_h_addr_start(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.h_sync +
               timing.h_back_porch +
               timing.h_left_border;
    end function;


    function get_h_addr_end(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.h_sync +
               timing.h_back_porch +
               timing.h_left_border +
               timing.h_addr_video;
    end function;


    function get_v_addr_start(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.v_sync +
               timing.v_back_porch +
               timing.v_top_border;
    end function;


    function get_v_addr_end(
        timing : t_vga_timing
    ) return natural is
    begin
        return timing.v_sync +
               timing.v_back_porch +
               timing.v_top_border +
               timing.v_addr_video;
    end function;

    function f_sync_output_level(
        sync_active : boolean;
        polarity    : t_sync_polarity
    ) return std_logic is
    begin
        case polarity is
            when ACTIVE_HIGH =>
                if sync_active then
                    return '1';
                else
                    return '0';
                end if;

            when ACTIVE_LOW =>
                if sync_active then
                    return '0';
                else
                    return '1';
                end if;
        end case;
    end function;

    function get_x_coord_width(
        mode : t_vga_mode
    ) return natural is
    begin
        case mode is
            when VGA_640X480_60 =>
                return 10;  -- 640 -> 10 bit
    
            when SVGA_800X600_60 =>
                return 10;  -- 800 -> 10 bit
    
            when XGA_1024X768_60 =>
                return 10;  -- 1024 -> 10 bit
        end case;
    end function;


    function get_y_coord_width(
        mode : t_vga_mode
    ) return natural is
    begin
        case mode is
            when VGA_640X480_60 =>
                return 9;   -- 480 -> 9 bit
    
            when SVGA_800X600_60 =>
                return 10;  -- 600 -> 10 bit
    
            when XGA_1024X768_60 =>
                return 10;  -- 768 -> 10 bit
        end case;
    end function;

end package body;
