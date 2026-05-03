library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;

entity vga_timing_generator is
    port (
        pixel_clk_i    : in  std_logic;
        sync_pos_rst_i : in  std_logic;
        vga_mode_i     : in  t_vga_mode;

        hsync_o        : out std_logic;
        vsync_o        : out std_logic;

        active_video_o : out std_logic;  -- border + addressable video
        video_on_o     : out std_logic;  -- addressable video only

        x_o            : out unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
        y_o            : out unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0)
    );
end entity vga_timing_generator;


architecture rtl of vga_timing_generator is

    constant C_X_COORD_WIDTH : natural := C_VGA_MAX_X_COORD_WIDTH;
    constant C_Y_COORD_WIDTH : natural := C_VGA_MAX_Y_COORD_WIDTH;
    constant C_DEFAULT_TIMING_CFG : t_vga_timing_derived := get_vga_timing_derived(VGA_640X480_60);

    signal timing_cfg_s      : t_vga_timing_derived := C_DEFAULT_TIMING_CFG;

    signal h_count_s         : natural range 0 to C_VGA_MAX_H_TOTAL - 1 := 0;
    signal v_count_s         : natural range 0 to C_VGA_MAX_V_TOTAL - 1 := 0;

    signal active_video_s     : std_logic;
    signal video_on_s         : std_logic;

begin

    timing_cfg_s <= get_vga_timing_derived(vga_mode_i);

    assert timing_cfg_s.h_total =
           timing_cfg_s.timing.h_sync +
           timing_cfg_s.timing.h_back_porch +
           timing_cfg_s.timing.h_left_border +
           timing_cfg_s.timing.h_addr_video +
           timing_cfg_s.timing.h_right_border +
           timing_cfg_s.timing.h_front_porch
        report "Horizontal timing sum mismatch."
        severity failure;

    assert timing_cfg_s.v_total =
           timing_cfg_s.timing.v_sync +
           timing_cfg_s.timing.v_back_porch +
           timing_cfg_s.timing.v_top_border +
           timing_cfg_s.timing.v_addr_video +
           timing_cfg_s.timing.v_bottom_border +
           timing_cfg_s.timing.v_front_porch
        report "Vertical timing sum mismatch."
        severity failure;

    assert timing_cfg_s.h_active_start <= timing_cfg_s.h_addr_start
        report "Horizontal active/addressable start relationship mismatch."
        severity failure;

    assert timing_cfg_s.h_addr_end <= timing_cfg_s.h_active_end
        report "Horizontal active/addressable end relationship mismatch."
        severity failure;

    assert timing_cfg_s.v_active_start <= timing_cfg_s.v_addr_start
        report "Vertical active/addressable start relationship mismatch."
        severity failure;

    assert timing_cfg_s.v_addr_end <= timing_cfg_s.v_active_end
        report "Vertical active/addressable end relationship mismatch."
        severity failure;


    process (pixel_clk_i)
    begin
        if rising_edge(pixel_clk_i) then
            if sync_pos_rst_i = '1' then 
                h_count_s <= 0;
                v_count_s <= 0;
            else
                if h_count_s >= timing_cfg_s.h_total - 1 then
                    h_count_s <= 0;

                    if v_count_s >= timing_cfg_s.v_total - 1 then
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
        sync_active => ((h_count_s >= timing_cfg_s.h_sync_start) and (h_count_s < timing_cfg_s.h_sync_end)),
        polarity    => timing_cfg_s.timing.h_polarity
    );

    vsync_o <= f_sync_output_level(
        sync_active => ((v_count_s >= timing_cfg_s.v_sync_start) and (v_count_s < timing_cfg_s.v_sync_end)),
        polarity    => timing_cfg_s.timing.v_polarity
    );


    active_video_s <= '1' when
        (h_count_s >= timing_cfg_s.h_active_start) and
        (h_count_s <  timing_cfg_s.h_active_end)   and
        (v_count_s >= timing_cfg_s.v_active_start) and
        (v_count_s <  timing_cfg_s.v_active_end)
        else '0';

    video_on_s <= '1' when
        (h_count_s >= timing_cfg_s.h_addr_start) and
        (h_count_s <  timing_cfg_s.h_addr_end)   and
        (v_count_s >= timing_cfg_s.v_addr_start) and
        (v_count_s <  timing_cfg_s.v_addr_end)
        else '0';


    active_video_o <= active_video_s;
    video_on_o     <= video_on_s;

    x_o <= to_unsigned(h_count_s - timing_cfg_s.h_addr_start, C_X_COORD_WIDTH) when video_on_s = '1'
           else (others => '0');

    y_o <= to_unsigned(v_count_s - timing_cfg_s.v_addr_start, C_Y_COORD_WIDTH) when video_on_s = '1'
           else (others => '0');

end architecture rtl;
