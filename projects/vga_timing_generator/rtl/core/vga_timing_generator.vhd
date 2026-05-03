library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;

entity vga_timing_generator is
    generic (
        G_VGA_MODE : t_vga_mode := VGA_640X480_60
    );
    port (
        pixel_clk_i    : in  std_logic;
        sync_pos_rst_i : in  std_logic;

        hsync_o        : out std_logic;
        vsync_o        : out std_logic;

        active_video_o : out std_logic;  -- border + addressable video
        video_on_o     : out std_logic;  -- addressable video only

        x_o            : out unsigned(get_x_coord_width(G_VGA_MODE) - 1 downto 0);
        y_o           : out unsigned(get_y_coord_width(G_VGA_MODE) - 1 downto 0)
    );
end entity vga_timing_generator;


architecture rtl of vga_timing_generator is

    constant C_TIMING : t_vga_timing := get_vga_timing(G_VGA_MODE);

    constant C_X_COORD_WIDTH : natural := get_x_coord_width(G_VGA_MODE);
    constant C_Y_COORD_WIDTH : natural := get_y_coord_width(G_VGA_MODE);

    -- Sync + BackPorch + LeftBorder + AddressableVideo + RightBorder + FrontPorch
    constant C_H_TOTAL        : natural := get_h_total(C_TIMING);
    constant C_V_TOTAL        : natural := get_v_total(C_TIMING);

    -- Cycles before the ActiveVideo
    -- Sync + Back Porch
    constant C_H_ACTIVE_START : natural := get_h_active_start(C_TIMING);
    constant C_V_ACTIVE_START : natural := get_v_active_start(C_TIMING);
    
    -- Cycles for the end of ActiveVideo
    -- Sync + BackPorch + LeftBorder + AddressableVideo + RightBorder
    constant C_H_ACTIVE_END   : natural := get_h_active_end(C_TIMING);
    constant C_V_ACTIVE_END   : natural := get_v_active_end(C_TIMING);

    -- Cycles to start the AddressableVideo region
    -- Sync + BackPorch + LeftBorder 
    constant C_H_ADDR_START   : natural := get_h_addr_start(C_TIMING);
    constant C_V_ADDR_START   : natural := get_v_addr_start(C_TIMING);
    
    -- Cycles to the end of the AddressableVideo region 
    -- Sync + BackPorch + LeftBorder + AddressableVideo
    constant C_H_ADDR_END     : natural := get_h_addr_end(C_TIMING);
    constant C_V_ADDR_END     : natural := get_v_addr_end(C_TIMING);

    constant C_H_SYNC_START   : natural := 0;
    constant C_V_SYNC_START   : natural := 0;
    
    constant C_H_SYNC_END     : natural := C_TIMING.h_sync;
    constant C_V_SYNC_END     : natural := C_TIMING.v_sync;

    signal h_count_s          : natural range 0 to C_H_TOTAL - 1 := 0;
    signal v_count_s          : natural range 0 to C_V_TOTAL - 1 := 0;

    signal active_video_s     : std_logic;
    signal video_on_s         : std_logic;

begin

    assert C_H_TOTAL =
           C_TIMING.h_sync +
           C_TIMING.h_back_porch +
           C_TIMING.h_left_border +
           C_TIMING.h_addr_video +
           C_TIMING.h_right_border +
           C_TIMING.h_front_porch
        report "Horizontal timing sum mismatch."
        severity failure;

    assert C_V_TOTAL =
           C_TIMING.v_sync +
           C_TIMING.v_back_porch +
           C_TIMING.v_top_border +
           C_TIMING.v_addr_video +
           C_TIMING.v_bottom_border +
           C_TIMING.v_front_porch
        report "Vertical timing sum mismatch."
        severity failure;

    assert C_H_ACTIVE_START <= C_H_ADDR_START
        report "Horizontal active/addressable start relationship mismatch."
        severity failure;

    assert C_H_ADDR_END <= C_H_ACTIVE_END
        report "Horizontal active/addressable end relationship mismatch."
        severity failure;

    assert C_V_ACTIVE_START <= C_V_ADDR_START
        report "Vertical active/addressable start relationship mismatch."
        severity failure;

    assert C_V_ADDR_END <= C_V_ACTIVE_END
        report "Vertical active/addressable end relationship mismatch."
        severity failure;


    process (pixel_clk_i)
    begin
        if rising_edge(pixel_clk_i) then
            if sync_pos_rst_i = '1' then 
                h_count_s <= 0;
                v_count_s <= 0;
            else
                if h_count_s = C_H_TOTAL - 1 then
                    h_count_s <= 0;

                    if v_count_s = C_V_TOTAL - 1 then
                        v_count_s <= 0;
                    else
                        v_count_s <= v_count_s + 1;
                    end if;
                else
                    h_count_s <= h_count_s + 1;
                end if;
            end if;
        end if;
    end process;


    hsync_o <= f_sync_output_level(
        sync_active => ((h_count_s >= C_H_SYNC_START) and (h_count_s < C_H_SYNC_END)),
        polarity    => C_TIMING.h_polarity
    );

    vsync_o <= f_sync_output_level(
        sync_active => ((v_count_s >= C_V_SYNC_START) and (v_count_s < C_V_SYNC_END)),
        polarity    => C_TIMING.v_polarity
    );


    active_video_s <= '1' when
        (h_count_s >= C_H_ACTIVE_START) and
        (h_count_s <  C_H_ACTIVE_END)   and
        (v_count_s >= C_V_ACTIVE_START) and
        (v_count_s <  C_V_ACTIVE_END)
        else '0';

    video_on_s <= '1' when
        (h_count_s >= C_H_ADDR_START) and
        (h_count_s <  C_H_ADDR_END)   and
        (v_count_s >= C_V_ADDR_START) and
        (v_count_s <  C_V_ADDR_END)
        else '0';


    active_video_o <= active_video_s;
    video_on_o     <= video_on_s;

    x_o <= to_unsigned(h_count_s - C_H_ADDR_START, C_X_COORD_WIDTH) when video_on_s = '1'
           else (others => '0');

    y_o <= to_unsigned(v_count_s - C_V_ADDR_START, C_Y_COORD_WIDTH) when video_on_s = '1'
           else (others => '0');

end architecture rtl;
