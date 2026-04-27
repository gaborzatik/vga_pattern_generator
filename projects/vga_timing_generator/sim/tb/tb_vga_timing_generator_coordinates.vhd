library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

use work.vga_timing_pkg.all;
use work.vga_timing_sim_pkg.all;

entity tb_vga_timing_generator_coordinates is
end entity tb_vga_timing_generator_coordinates;

architecture sim of tb_vga_timing_generator_coordinates is

    constant C_MODE             : t_vga_mode := VGA_640X480_60;
    constant C_TIMING           : t_vga_timing := get_vga_timing(C_MODE);
    constant C_H_TOTAL          : natural := get_h_total(C_TIMING);
    constant C_H_ADDR_END       : natural := get_h_addr_end(C_TIMING);
    constant C_H_ADDR_START     : natural := get_h_addr_start(C_TIMING);
    constant C_ACTIVE_WIDTH     : natural := C_TIMING.h_addr_video;
    constant C_ACTIVE_HEIGHT    : natural := C_TIMING.v_addr_video;
    constant C_CLK_PERIOD       : time := 10 ns;

    signal pixel_clk_s          : std_logic := '0';
    signal sync_pos_rst_s       : std_logic := '1';

    signal hsync_s              : std_logic;
    signal vsync_s              : std_logic;
    signal active_video_s       : std_logic;
    signal video_on_s           : std_logic;
    signal x_s                  : unsigned(get_x_coord_width(C_MODE) - 1 downto 0);
    signal y_s                  : unsigned(get_y_coord_width(C_MODE) - 1 downto 0);

begin

    pixel_clk_s <= not pixel_clk_s after C_CLK_PERIOD / 2;

    dut : entity work.vga_timing_generator
        generic map (
            G_VGA_MODE => C_MODE
        )
        port map (
            pixel_clk_i    => pixel_clk_s,
            sync_pos_rst_i => sync_pos_rst_s,
            hsync_o        => hsync_s,
            vsync_o        => vsync_s,
            active_video_o => active_video_s,
            video_on_o     => video_on_s,
            x_o            => x_s,
            y_o            => y_s
        );

    stimulus : process
        constant C_TO_NEXT_LINE_START : natural := (C_H_TOTAL - C_H_ADDR_END) + C_H_ADDR_START;
        constant C_TO_LAST_LINE_START : natural := (C_ACTIVE_HEIGHT - 2) * C_H_TOTAL;
    begin
        wait until rising_edge(pixel_clk_s);
        wait until rising_edge(pixel_clk_s);
        sync_pos_rst_s <= '0';

        while active_video_s /= '1' loop
            wait until rising_edge(pixel_clk_s);
        end loop;

        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '0',
            message  => "video_on_o must still be low at the first active-video border pixel."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must stay zero before the addressable region starts."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o must stay zero before the addressable region starts."
        );

        while video_on_s /= '1' loop
            wait until rising_edge(pixel_clk_s);
        end loop;

        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must start from zero at the first addressable pixel."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o must start from zero on the first addressable line."
        );

        for expected_x_v in 1 to 4 loop
            wait until rising_edge(pixel_clk_s);
            assert_std_logic_equal(
                actual   => video_on_s,
                expected => '1',
                message  => "video_on_o must stay high while stepping through the first line."
            );
            assert_unsigned_equal(
                actual   => x_s,
                expected => expected_x_v,
                message  => "x_o increment mismatch on the first addressable line."
            );
            assert_unsigned_equal(
                actual   => y_s,
                expected => 0,
                message  => "y_o must stay on the first line while x_o increments."
            );
        end loop;

        for i in 1 to (C_ACTIVE_WIDTH - 1 - 4) loop
            wait until rising_edge(pixel_clk_s);
        end loop;

        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '1',
            message  => "video_on_o must still be high at the last pixel of the first line."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => C_ACTIVE_WIDTH - 1,
            message  => "x_o mismatch at the last pixel of the first addressable line."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o mismatch at the last pixel of the first addressable line."
        );

        wait until rising_edge(pixel_clk_s);
        assert_std_logic_equal(
            actual   => active_video_s,
            expected => '1',
            message  => "active_video_o must stay high in the horizontal border after the addressable region."
        );
        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '0',
            message  => "video_on_o must drop immediately after the last addressable pixel."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must return to zero outside the addressable region."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o must return to zero outside the addressable region."
        );

        for i in 1 to C_TO_NEXT_LINE_START loop
            wait until rising_edge(pixel_clk_s);
        end loop;

        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '1',
            message  => "video_on_o must reassert at the first pixel of the second line."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must restart from zero on the second addressable line."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 1,
            message  => "y_o must increment to one on the second addressable line."
        );

        for i in 1 to C_TO_LAST_LINE_START loop
            wait until rising_edge(pixel_clk_s);
        end loop;

        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '1',
            message  => "video_on_o must be high at the start of the last addressable line."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must restart from zero on the last addressable line."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => C_ACTIVE_HEIGHT - 1,
            message  => "y_o mismatch on the last addressable line."
        );

        for i in 1 to C_ACTIVE_WIDTH - 1 loop
            wait until rising_edge(pixel_clk_s);
        end loop;

        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '1',
            message  => "video_on_o must still be high at the last pixel of the last line."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => C_ACTIVE_WIDTH - 1,
            message  => "x_o mismatch at the last pixel of the last line."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => C_ACTIVE_HEIGHT - 1,
            message  => "y_o mismatch at the last pixel of the last line."
        );

        wait until rising_edge(pixel_clk_s);
        assert_std_logic_equal(
            actual   => video_on_s,
            expected => '0',
            message  => "video_on_o must drop after the final addressable pixel of the frame."
        );
        assert_unsigned_equal(
            actual   => x_s,
            expected => 0,
            message  => "x_o must clear after the final addressable pixel of the frame."
        );
        assert_unsigned_equal(
            actual   => y_s,
            expected => 0,
            message  => "y_o must clear after the final addressable pixel of the frame."
        );

        report "tb_vga_timing_generator_coordinates completed successfully."
            severity note;
        finish;
    end process;

end architecture sim;
