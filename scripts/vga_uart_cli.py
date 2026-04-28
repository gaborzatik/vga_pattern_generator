#!/usr/bin/env python3
"""Send VGA pattern-generator control commands over an 8N1 UART link."""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass


UART_BAUD_RATE = 9_600
UART_OP_VGA_MODE_SELECT = 0b00
UART_OP_VGA_CLOCK_SELECT = 0b01

PATTERN_MODES = [
    "BLACK",
    "WHITE",
    "RED",
    "GREEN",
    "BLUE",
    "GRAY_10",
    "GRAY_50",
    "GRAY_80",
    "COLOR_BARS",
    "GRAYSCALE_RAMP",
    "CHECKER_1PX",
    "CHECKER_2PX",
    "CHECKER_4PX",
    "CHECKER_8PX",
    "BORDER_1PX",
    "PLUGE_BLACK",
    "PLUGE_WHITE",
    "CENTER_CROSS",
    "CORNER_MARKERS",
    "CROSSHATCH_COARSE",
    "CROSSHATCH_FINE",
    "CIRCLE",
    "CIRCLE_GRID",
    "LINEARITY_V",
    "LINEARITY_H",
    "STRIPES_V_1PX",
    "STRIPES_H_1PX",
    "BURST_V",
    "BURST_H",
    "FOCUS_TEXT",
    "DIAGONAL_TEST",
    "RGB_REGISTRATION",
    "UNIFORM_DARK",
    "UNIFORM_MID",
    "UNIFORM_LIGHT",
    "MOVING_BAR_H",
    "MOVING_BAR_V",
    "SCROLL_CHECKER",
    "X_RAMP",
    "Y_RAMP",
    "XY_RAMP",
    "ACTIVE_VIDEO_DEBUG",
    "MODE_OVERLAY",
    "FRAME_MARKER",
]


@dataclass(frozen=True)
class ClockMode:
    name: str
    pixel_clock_hz: int


CLOCK_MODES = [
    ClockMode("VGA_640X480_60", 25_175_000),
    ClockMode("SVGA_800X600_60", 40_000_000),
    ClockMode("XGA_1024X768_60", 65_000_000),
]


def parse_enum_value(value: str, names: list[str]) -> int:
    try:
        parsed = int(value, 0)
    except ValueError:
        normalized = value.upper()
        if normalized not in names:
            valid = ", ".join(names)
            raise argparse.ArgumentTypeError(f"unknown value {value!r}; valid names: {valid}")
        parsed = names.index(normalized)

    if not 0 <= parsed <= 0x3F:
        raise argparse.ArgumentTypeError("enum value must fit in the 6-bit UART payload")
    return parsed


def make_payload(operation_id: int, enum_value: int) -> int:
    return ((operation_id & 0b11) << 6) | (enum_value & 0x3F)


def open_serial(port: str):
    try:
        import serial
    except ImportError as exc:
        raise SystemExit(
            "pyserial is required. Install it with: python -m pip install pyserial"
        ) from exc

    return serial.Serial(
        port=port,
        baudrate=UART_BAUD_RATE,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        timeout=1.0,
        write_timeout=1.0,
    )


def send_payload(port: str, payload: int) -> None:
    with open_serial(port) as serial_port:
        serial_port.write(bytes([payload]))
        serial_port.flush()


def list_values() -> None:
    print("Pattern modes:")
    for index, name in enumerate(PATTERN_MODES):
        print(f"  {index:02d}  {name}")

    print("\nClock modes:")
    for index, clock in enumerate(CLOCK_MODES):
        mhz = clock.pixel_clock_hz / 1_000_000
        print(f"  {index:02d}  {clock.name}  ({mhz:g} MHz)")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Control the Basys3 VGA pattern generator over UART 8N1."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    mode_parser = subparsers.add_parser("mode", help="send VGA_MODE_SELECT")
    mode_parser.add_argument("--port", required=True, help="serial port, for example COM5")
    mode_parser.add_argument("value", help="pattern enum name or 6-bit numeric value")

    clock_parser = subparsers.add_parser("clock", help="send VGA_CLOCK_SELECT")
    clock_parser.add_argument("--port", required=True, help="serial port, for example COM5")
    clock_parser.add_argument("value", help="clock enum name or 6-bit numeric value")

    raw_parser = subparsers.add_parser("raw", help="send one raw payload byte")
    raw_parser.add_argument("--port", required=True, help="serial port, for example COM5")
    raw_parser.add_argument("byte", type=lambda value: int(value, 0), help="byte value, for example 0x02")

    subparsers.add_parser("list", help="list known enum names")

    return parser


def main(argv: list[str]) -> int:
    args = build_parser().parse_args(argv)

    if args.command == "list":
        list_values()
        return 0

    if args.command == "mode":
        enum_value = parse_enum_value(args.value, PATTERN_MODES)
        payload = make_payload(UART_OP_VGA_MODE_SELECT, enum_value)
        send_payload(args.port, payload)
        print(f"sent VGA_MODE_SELECT value={enum_value} payload=0x{payload:02X}")
        return 0

    if args.command == "clock":
        enum_value = parse_enum_value(args.value, [clock.name for clock in CLOCK_MODES])
        payload = make_payload(UART_OP_VGA_CLOCK_SELECT, enum_value)
        send_payload(args.port, payload)
        print(f"sent VGA_CLOCK_SELECT value={enum_value} payload=0x{payload:02X}")
        return 0

    if args.command == "raw":
        if not 0 <= args.byte <= 0xFF:
            raise SystemExit("raw byte must be in range 0x00..0xFF")
        send_payload(args.port, args.byte)
        print(f"sent raw payload=0x{args.byte:02X}")
        return 0

    raise SystemExit(f"unknown command: {args.command}")


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
