library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vga_pattern_common_pkg is

    -- =========================================================================
    -- Color types
    -- =========================================================================

    constant C_RGB_WIDTH : natural := 4;

    subtype t_rgb_channel is std_logic_vector(C_RGB_WIDTH - 1 downto 0);

    type t_rgb_color is record
        red   : t_rgb_channel;
        green : t_rgb_channel;
        blue  : t_rgb_channel;
    end record;

    -- =========================================================================
    -- Pattern mode types
    -- =========================================================================

    type t_pattern_mode is (
        BLACK,
        WHITE,
        RED,
        GREEN,
        BLUE,
        GRAY_10,
        GRAY_50,
        GRAY_80,
        COLOR_BARS,
        GRAYSCALE_RAMP,
        CHECKER_1PX,
        CHECKER_2PX,
        CHECKER_4PX,
        CHECKER_8PX,        
        PLUGE_BLACK,
        PLUGE_WHITE,
        BORDER_1PX,
        CENTER_CROSS,
        CORNER_MARKERS,
        CROSSHATCH_COARSE,
        CROSSHATCH_FINE,
        CIRCLE,
        CIRCLE_GRID,
        LINEARITY_V,
        LINEARITY_H,
        STRIPES_V_1PX,
        STRIPES_H_1PX,
        BURST_V,
        BURST_H,
        FOCUS_TEXT,
        DIAGONAL_TEST,
        RGB_REGISTRATION,
        UNIFORM_DARK,
        UNIFORM_MID,
        UNIFORM_LIGHT,
        MOVING_BAR_H,
        MOVING_BAR_V,
        SCROLL_CHECKER,
        X_RAMP,
        Y_RAMP,
        XY_RAMP,
        ACTIVE_VIDEO_DEBUG,
        MODE_OVERLAY,
        FRAME_MARKER
    );

    type t_pattern_rgb_array is array (t_pattern_mode) of t_rgb_color;

    constant C_PATTERN_COUNT : natural := t_pattern_mode'pos(t_pattern_mode'right) + 1;

    -- =========================================================================
    -- Generic utility functions
    -- =========================================================================

    function required_bit_width(
        value_count : natural
    ) return natural;

    function max_channel_value
        return natural;

    function channel_from_level(
        level : natural
    ) return t_rgb_channel;

    function channel_from_percent(
        percent : natural
    ) return t_rgb_channel;

    function color_from_channels(
        red   : t_rgb_channel;
        green : t_rgb_channel;
        blue  : t_rgb_channel
    ) return t_rgb_color;

    function gray_color_from_channel(
        gray : t_rgb_channel
    ) return t_rgb_color;

    function gray_color_from_level(
        level : natural
    ) return t_rgb_color;

    function gray_channel_from_position(
        position      : unsigned;
        active_length : natural
    ) return t_rgb_channel;

    -- =========================================================================
    -- Selector types
    -- =========================================================================

    constant C_PATTERN_SEL_WIDTH : natural := required_bit_width(C_PATTERN_COUNT);

    subtype t_pattern_sel_slv is std_logic_vector(C_PATTERN_SEL_WIDTH - 1 downto 0);

    -- =========================================================================
    -- Color constants
    -- =========================================================================

    constant C_RGB_BLACK : t_rgb_color := (
        red   => (others => '0'),
        green => (others => '0'),
        blue  => (others => '0')
    );

    constant C_RGB_WHITE : t_rgb_color := (
        red   => (others => '1'),
        green => (others => '1'),
        blue  => (others => '1')
    );

    constant C_RGB_RED : t_rgb_color := (
        red   => (others => '1'),
        green => (others => '0'),
        blue  => (others => '0')
    );

    constant C_RGB_GREEN : t_rgb_color := (
        red   => (others => '0'),
        green => (others => '1'),
        blue  => (others => '0')
    );

    constant C_RGB_BLUE : t_rgb_color := (
        red   => (others => '0'),
        green => (others => '0'),
        blue  => (others => '1')
    );

    constant C_RGB_YELLOW : t_rgb_color := (
        red   => (others => '1'),
        green => (others => '1'),
        blue  => (others => '0')
    );

    constant C_RGB_CYAN : t_rgb_color := (
        red   => (others => '0'),
        green => (others => '1'),
        blue  => (others => '1')
    );

    constant C_RGB_MAGENTA : t_rgb_color := (
        red   => (others => '1'),
        green => (others => '0'),
        blue  => (others => '1')
    );

    -- =========================================================================
    -- Coordinate / geometry helpers
    -- =========================================================================

    type t_cell_end_array is array (natural range <>) of natural;

    function pattern_mode_from_select(
        sel : t_pattern_sel_slv
    ) return t_pattern_mode;

    function pattern_select_from_mode(
        mode : t_pattern_mode
    ) return t_pattern_sel_slv;

    function cell_index_from_coordinate(
        coord     : unsigned;
        cell_ends : t_cell_end_array
    ) return natural;

end package vga_pattern_common_pkg;


package body vga_pattern_common_pkg is

    function required_bit_width(
        value_count : natural
    ) return natural is
        variable v_bits  : natural := 0;
        variable v_limit : natural := 1;
    begin
        if value_count <= 1 then
            return 1;
        end if;

        while v_limit < value_count loop
            v_bits  := v_bits + 1;
            v_limit := v_limit * 2;
        end loop;

        return v_bits;
    end function;

    function max_channel_value
        return natural is
    begin
        return (2 ** C_RGB_WIDTH) - 1;
    end function;

    function channel_from_level(
        level : natural
    ) return t_rgb_channel is
        variable v_level : natural;
    begin
        if level > max_channel_value then
            v_level := max_channel_value;
        else
            v_level := level;
        end if;

        return std_logic_vector(
            to_unsigned(
                v_level,
                C_RGB_WIDTH
            )
        );
    end function;

    function channel_from_percent(
        percent : natural
    ) return t_rgb_channel is
        variable v_percent : natural;
        variable v_level   : natural;
    begin
        if percent > 100 then
            v_percent := 100;
        else
            v_percent := percent;
        end if;

        v_level := (v_percent * max_channel_value + 50) / 100;

        return channel_from_level(v_level);
    end function;

    function color_from_channels(
        red   : t_rgb_channel;
        green : t_rgb_channel;
        blue  : t_rgb_channel
    ) return t_rgb_color is
    begin
        return (
            red   => red,
            green => green,
            blue  => blue
        );
    end function;

    function gray_color_from_channel(
        gray : t_rgb_channel
    ) return t_rgb_color is
    begin
        return color_from_channels(
            red   => gray,
            green => gray,
            blue  => gray
        );
    end function;

    function gray_color_from_level(
        level : natural
    ) return t_rgb_color is
    begin
        return gray_color_from_channel(
            channel_from_level(level)
        );
    end function;

    function gray_color_from_percent(
        percent : natural
    ) return t_rgb_color is
    begin
        return gray_color_from_channel(
            channel_from_percent(percent)
        );
    end function;

    function gray_channel_from_position(
        position      : unsigned;
        active_length : natural
    ) return t_rgb_channel is
        variable v_level : natural;
    begin
        if active_length <= 1 then
            return channel_from_level(0);
        elsif to_integer(position) >= active_length then
            return channel_from_level(max_channel_value);
        else
            v_level := (to_integer(position) * (max_channel_value + 1)) / active_length;
    
            if v_level > max_channel_value then
                v_level := max_channel_value;
            end if;
    
            return channel_from_level(v_level);
        end if;
    end function;

    function pattern_mode_from_select(
        sel : t_pattern_sel_slv
    ) return t_pattern_mode is
        variable v_idx : natural;
    begin
        v_idx := to_integer(unsigned(sel));

        if v_idx < C_PATTERN_COUNT then
            return t_pattern_mode'val(v_idx);
        else
            assert false
                report "Invalid pattern selector value"
                severity warning;
            return BLACK;
        end if;
    end function;

    function pattern_select_from_mode(
        mode : t_pattern_mode
    ) return t_pattern_sel_slv is
    begin
        return std_logic_vector(
            to_unsigned(
                t_pattern_mode'pos(mode),
                C_PATTERN_SEL_WIDTH
            )
        );
    end function;

    function cell_index_from_coordinate(
        coord     : unsigned;
        cell_ends : t_cell_end_array
    ) return natural is
    begin
        for i in cell_ends'range loop
            if coord < to_unsigned(cell_ends(i), coord'length) then
                return i;
            end if;
        end loop;

        -- No matching cell found; return one-past-the-last valid index.
        return cell_ends'length;
    end function;

end package body vga_pattern_common_pkg;