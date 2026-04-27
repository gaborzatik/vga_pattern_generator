library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_timing_pkg.all;

package vga_timing_sim_pkg is

    function expected_sync_level(
        sync_active : boolean;
        polarity    : t_sync_polarity
    ) return std_logic;

    function std_logic_to_string(
        value : std_logic
    ) return string;

    function unsigned_to_string(
        value : unsigned
    ) return string;

    procedure assert_std_logic_equal(
        actual   : std_logic;
        expected : std_logic;
        message  : string
    );

    procedure assert_unsigned_equal(
        actual   : unsigned;
        expected : natural;
        message  : string
    );

    procedure assert_natural_equal(
        actual   : natural;
        expected : natural;
        message  : string
    );

end package vga_timing_sim_pkg;

package body vga_timing_sim_pkg is

    function expected_sync_level(
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

    function std_logic_to_string(
        value : std_logic
    ) return string is
    begin
        return std_logic'image(value);
    end function;

    function unsigned_to_string(
        value : unsigned
    ) return string is
    begin
        return integer'image(to_integer(value));
    end function;

    procedure assert_std_logic_equal(
        actual   : std_logic;
        expected : std_logic;
        message  : string
    ) is
    begin
        assert actual = expected
            report message &
                   " Expected " & std_logic_to_string(expected) &
                   ", got " & std_logic_to_string(actual)
            severity failure;
    end procedure;

    procedure assert_unsigned_equal(
        actual   : unsigned;
        expected : natural;
        message  : string
    ) is
    begin
        assert actual = to_unsigned(expected, actual'length)
            report message &
                   " Expected " & integer'image(expected) &
                   ", got " & unsigned_to_string(actual)
            severity failure;
    end procedure;

    procedure assert_natural_equal(
        actual   : natural;
        expected : natural;
        message  : string
    ) is
    begin
        assert actual = expected
            report message &
                   " Expected " & integer'image(expected) &
                   ", got " & integer'image(actual)
            severity failure;
    end procedure;

end package body vga_timing_sim_pkg;
