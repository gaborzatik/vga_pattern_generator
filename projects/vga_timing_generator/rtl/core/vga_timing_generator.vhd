library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;

entity vga_timing_generator is
    port (
        pixel_clk_i         : in  std_logic;
        sync_pos_rst_i      : in  std_logic;
        mode_i              : in  t_vga_mode;
        hold_i              : in  std_logic;

        hsync_o             : out std_logic;
        vsync_o             : out std_logic;

        active_video_o      : out std_logic;  -- border + addressable video
        video_on_o          : out std_logic;  -- addressable video only

        x_o                 : out unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
        y_o                 : out unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0);

        mode_switch_safe_o  : out std_logic;
        hold_active_o       : out std_logic
    );
end entity vga_timing_generator;


architecture rtl of vga_timing_generator is

    type t_runtime_timing_cfg is record
        h_total        : natural;
        v_total        : natural;
        h_active_start : natural;
        h_active_end   : natural;
        v_active_start : natural;
        v_active_end   : natural;
        h_addr_start   : natural;
        h_addr_end     : natural;
        v_addr_start   : natural;
        v_addr_end     : natural;
        h_sync_start   : natural;
        h_sync_end     : natural;
        v_sync_start   : natural;
        v_sync_end     : natural;
        h_polarity     : t_sync_polarity;
        v_polarity     : t_sync_polarity;
    end record;

    function f_runtime_timing_cfg(
        mode : t_vga_mode
    ) return t_runtime_timing_cfg is
        variable derived_v : t_vga_timing_derived;
        variable cfg_v     : t_runtime_timing_cfg;
    begin
        derived_v := get_vga_timing_derived(mode);

        cfg_v.h_total        := derived_v.h_total;
        cfg_v.v_total        := derived_v.v_total;
        cfg_v.h_active_start := derived_v.h_active_start;
        cfg_v.h_active_end   := derived_v.h_active_end;
        cfg_v.v_active_start := derived_v.v_active_start;
        cfg_v.v_active_end   := derived_v.v_active_end;
        cfg_v.h_addr_start   := derived_v.h_addr_start;
        cfg_v.h_addr_end     := derived_v.h_addr_end;
        cfg_v.v_addr_start   := derived_v.v_addr_start;
        cfg_v.v_addr_end     := derived_v.v_addr_end;
        cfg_v.h_sync_start   := derived_v.h_sync_start;
        cfg_v.h_sync_end     := derived_v.h_sync_end;
        cfg_v.v_sync_start   := derived_v.v_sync_start;
        cfg_v.v_sync_end     := derived_v.v_sync_end;
        cfg_v.h_polarity     := derived_v.timing.h_polarity;
        cfg_v.v_polarity     := derived_v.timing.v_polarity;

        return cfg_v;
    end function;

    constant C_X_COORD_WIDTH : natural := C_VGA_MAX_X_COORD_WIDTH;
    constant C_Y_COORD_WIDTH : natural := C_VGA_MAX_Y_COORD_WIDTH;
    constant C_DEFAULT_TIMING_CFG : t_runtime_timing_cfg := f_runtime_timing_cfg(XGA_1024X768_60);

    signal timing_cfg_s      : t_runtime_timing_cfg := C_DEFAULT_TIMING_CFG;

    signal h_count_s         : natural range 0 to C_VGA_MAX_H_TOTAL - 1 := 0;
    signal v_count_s         : natural range 0 to C_VGA_MAX_V_TOTAL - 1 := 0;
    signal run_started_s     : std_logic := '0';

    signal active_video_s     : std_logic;
    signal video_on_s         : std_logic;
    signal timing_held_s      : std_logic;

begin

    timing_cfg_s <= f_runtime_timing_cfg(mode_i);
    timing_held_s <= sync_pos_rst_i or hold_i;

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
            if sync_pos_rst_i = '1' or hold_i = '1' then 
                h_count_s <= 0;
                v_count_s <= 0;
                run_started_s <= '0';
            else
                if run_started_s = '0' then
                    run_started_s <= '1';
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
        end if;
    end process;


    hsync_o <= f_sync_output_level(
        sync_active => false,
        polarity    => timing_cfg_s.h_polarity
    ) when timing_held_s = '1' else f_sync_output_level(
        sync_active => ((h_count_s >= timing_cfg_s.h_sync_start) and (h_count_s < timing_cfg_s.h_sync_end)),
        polarity    => timing_cfg_s.h_polarity
    );

    vsync_o <= f_sync_output_level(
        sync_active => false,
        polarity    => timing_cfg_s.v_polarity
    ) when timing_held_s = '1' else f_sync_output_level(
        sync_active => ((v_count_s >= timing_cfg_s.v_sync_start) and (v_count_s < timing_cfg_s.v_sync_end)),
        polarity    => timing_cfg_s.v_polarity
    );


    active_video_s <= '1' when timing_held_s = '0' and
        (h_count_s >= timing_cfg_s.h_active_start) and
        (h_count_s <  timing_cfg_s.h_active_end)   and
        (v_count_s >= timing_cfg_s.v_active_start) and
        (v_count_s <  timing_cfg_s.v_active_end)
        else '0';

    video_on_s <= '1' when timing_held_s = '0' and
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

    mode_switch_safe_o <= '1' when timing_held_s = '0' and h_count_s = 0 and v_count_s = 0 else '0';
    hold_active_o      <= hold_i;

end architecture rtl;
