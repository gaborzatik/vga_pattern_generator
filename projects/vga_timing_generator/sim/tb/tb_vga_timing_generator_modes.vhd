library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_timing_pkg.all;
use work.vga_timing_sim_pkg.all;

entity tb_vga_timing_generator_modes is
end entity tb_vga_timing_generator_modes;

architecture sim of tb_vga_timing_generator_modes is

    constant C_CLK_PERIOD : time := 10 ns;

    signal pixel_clk_s    : std_logic := '0';
    signal sync_pos_rst_s : std_logic := '1';

    signal vga_hsync_s    : std_logic;
    signal vga_vsync_s    : std_logic;
    signal vga_active_s   : std_logic;
    signal vga_video_s    : std_logic;
    signal vga_x_s        : unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
    signal vga_y_s        : unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0);

    signal svga_hsync_s   : std_logic;
    signal svga_vsync_s   : std_logic;
    signal svga_active_s  : std_logic;
    signal svga_video_s   : std_logic;
    signal svga_x_s       : unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
    signal svga_y_s       : unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0);

    signal xga_hsync_s    : std_logic;
    signal xga_vsync_s    : std_logic;
    signal xga_active_s   : std_logic;
    signal xga_video_s    : std_logic;
    signal xga_x_s        : unsigned(C_VGA_MAX_X_COORD_WIDTH - 1 downto 0);
    signal xga_y_s        : unsigned(C_VGA_MAX_Y_COORD_WIDTH - 1 downto 0);

    signal vga_done_s     : std_logic := '0';
    signal svga_done_s    : std_logic := '0';
    signal xga_done_s     : std_logic := '0';

    procedure check_mode_frame(
        constant mode       : t_vga_mode;
        constant mode_name  : string;
        signal clk          : in std_logic;
        signal hsync_o      : in std_logic;
        signal vsync_o      : in std_logic;
        signal active_o     : in std_logic;
        signal video_o      : in std_logic;
        signal x_o          : in unsigned;
        signal y_o          : in unsigned
    ) is
        constant C_TIMING         : t_vga_timing := get_vga_timing(mode);
        constant C_H_TOTAL        : natural := get_h_total(C_TIMING);
        constant C_V_TOTAL        : natural := get_v_total(C_TIMING);
        constant C_H_ACTIVE_START : natural := get_h_active_start(C_TIMING);
        constant C_H_ACTIVE_END   : natural := get_h_active_end(C_TIMING);
        constant C_V_ACTIVE_START : natural := get_v_active_start(C_TIMING);
        constant C_V_ACTIVE_END   : natural := get_v_active_end(C_TIMING);
        constant C_H_ADDR_START   : natural := get_h_addr_start(C_TIMING);
        constant C_H_ADDR_END     : natural := get_h_addr_end(C_TIMING);
        constant C_V_ADDR_START   : natural := get_v_addr_start(C_TIMING);
        constant C_V_ADDR_END     : natural := get_v_addr_end(C_TIMING);

        variable exp_h_count_v    : natural := 0;
        variable exp_v_count_v    : natural := 0;
        variable exp_active_v     : boolean;
        variable exp_video_v      : boolean;
        variable exp_x_v          : natural;
        variable exp_y_v          : natural;
        variable exp_active_sl_v  : std_logic;
        variable exp_video_sl_v   : std_logic;
    begin
        for cycle in 1 to C_H_TOTAL * C_V_TOTAL loop
            wait until rising_edge(clk);

            if exp_h_count_v = C_H_TOTAL - 1 then
                exp_h_count_v := 0;

                if exp_v_count_v = C_V_TOTAL - 1 then
                    exp_v_count_v := 0;
                else
                    exp_v_count_v := exp_v_count_v + 1;
                end if;
            else
                exp_h_count_v := exp_h_count_v + 1;
            end if;

            exp_active_v :=
                (exp_h_count_v >= C_H_ACTIVE_START) and
                (exp_h_count_v <  C_H_ACTIVE_END)   and
                (exp_v_count_v >= C_V_ACTIVE_START) and
                (exp_v_count_v <  C_V_ACTIVE_END);

            exp_video_v :=
                (exp_h_count_v >= C_H_ADDR_START) and
                (exp_h_count_v <  C_H_ADDR_END)   and
                (exp_v_count_v >= C_V_ADDR_START) and
                (exp_v_count_v <  C_V_ADDR_END);

            if exp_video_v then
                exp_x_v := exp_h_count_v - C_H_ADDR_START;
                exp_y_v := exp_v_count_v - C_V_ADDR_START;
            else
                exp_x_v := 0;
                exp_y_v := 0;
            end if;

            if exp_active_v then
                exp_active_sl_v := '1';
            else
                exp_active_sl_v := '0';
            end if;

            if exp_video_v then
                exp_video_sl_v := '1';
            else
                exp_video_sl_v := '0';
            end if;

            assert_std_logic_equal(
                actual   => hsync_o,
                expected => expected_sync_level(exp_h_count_v < C_TIMING.h_sync, C_TIMING.h_polarity),
                message  => mode_name & ": hsync mismatch."
            );
            assert_std_logic_equal(
                actual   => vsync_o,
                expected => expected_sync_level(exp_v_count_v < C_TIMING.v_sync, C_TIMING.v_polarity),
                message  => mode_name & ": vsync mismatch."
            );
            assert_std_logic_equal(
                actual   => active_o,
                expected => exp_active_sl_v,
                message  => mode_name & ": active_video mismatch."
            );
            assert_std_logic_equal(
                actual   => video_o,
                expected => exp_video_sl_v,
                message  => mode_name & ": video_on mismatch."
            );
            assert_unsigned_equal(
                actual   => x_o,
                expected => exp_x_v,
                message  => mode_name & ": x_o mismatch."
            );
            assert_unsigned_equal(
                actual   => y_o,
                expected => exp_y_v,
                message  => mode_name & ": y_o mismatch."
            );
        end loop;
    end procedure;

begin

    pixel_clk_s <= not pixel_clk_s after C_CLK_PERIOD / 2;

    dut_vga : entity work.vga_timing_generator
        port map (
            pixel_clk_i    => pixel_clk_s,
            sync_pos_rst_i => sync_pos_rst_s,
            vga_mode_i     => VGA_640X480_60,
            hsync_o        => vga_hsync_s,
            vsync_o        => vga_vsync_s,
            active_video_o => vga_active_s,
            video_on_o     => vga_video_s,
            x_o            => vga_x_s,
            y_o            => vga_y_s
        );

    dut_svga : entity work.vga_timing_generator
        port map (
            pixel_clk_i    => pixel_clk_s,
            sync_pos_rst_i => sync_pos_rst_s,
            vga_mode_i     => SVGA_800X600_60,
            hsync_o        => svga_hsync_s,
            vsync_o        => svga_vsync_s,
            active_video_o => svga_active_s,
            video_on_o     => svga_video_s,
            x_o            => svga_x_s,
            y_o            => svga_y_s
        );

    dut_xga : entity work.vga_timing_generator
        port map (
            pixel_clk_i    => pixel_clk_s,
            sync_pos_rst_i => sync_pos_rst_s,
            vga_mode_i     => XGA_1024X768_60,
            hsync_o        => xga_hsync_s,
            vsync_o        => xga_vsync_s,
            active_video_o => xga_active_s,
            video_on_o     => xga_video_s,
            x_o            => xga_x_s,
            y_o            => xga_y_s
        );

    control : process
    begin
        wait until rising_edge(pixel_clk_s);
        wait until rising_edge(pixel_clk_s);
        sync_pos_rst_s <= '0';
        wait;
    end process;

    check_vga : process
    begin
        wait until sync_pos_rst_s = '0';
        check_mode_frame(
            mode      => VGA_640X480_60,
            mode_name => "VGA_640X480_60",
            clk       => pixel_clk_s,
            hsync_o   => vga_hsync_s,
            vsync_o   => vga_vsync_s,
            active_o  => vga_active_s,
            video_o   => vga_video_s,
            x_o       => vga_x_s,
            y_o       => vga_y_s
        );
        vga_done_s <= '1';
        wait;
    end process;

    check_svga : process
    begin
        wait until sync_pos_rst_s = '0';
        check_mode_frame(
            mode      => SVGA_800X600_60,
            mode_name => "SVGA_800X600_60",
            clk       => pixel_clk_s,
            hsync_o   => svga_hsync_s,
            vsync_o   => svga_vsync_s,
            active_o  => svga_active_s,
            video_o   => svga_video_s,
            x_o       => svga_x_s,
            y_o       => svga_y_s
        );
        svga_done_s <= '1';
        wait;
    end process;

    check_xga : process
    begin
        wait until sync_pos_rst_s = '0';
        check_mode_frame(
            mode      => XGA_1024X768_60,
            mode_name => "XGA_1024X768_60",
            clk       => pixel_clk_s,
            hsync_o   => xga_hsync_s,
            vsync_o   => xga_vsync_s,
            active_o  => xga_active_s,
            video_o   => xga_video_s,
            x_o       => xga_x_s,
            y_o       => xga_y_s
        );
        xga_done_s <= '1';
        wait;
    end process;

    finish_when_done : process
    begin
        wait until (vga_done_s = '1') and (svga_done_s = '1') and (xga_done_s = '1');
        report "tb_vga_timing_generator_modes completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
