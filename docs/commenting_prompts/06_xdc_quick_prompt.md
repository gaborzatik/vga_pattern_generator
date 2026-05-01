# XDC Quick Commenting Prompt

Use this compact version when Codex already has enough project context.

```text
Apply strict review-grade XDC documentation comments to this constraint file.

COMMENT-ONLY MODE:
Do not change any non-comment line.
Do not add, remove, modify, reorder, comment out, uncomment, reformat, or replace any XDC command.
Only add or improve "#" comments.

Add useful comments that explain:
- file purpose and project scope,
- target board/device if clear,
- clock constraints,
- generated clocks or Clocking Wizard assumptions,
- pin mappings,
- I/O standards,
- I/O delay assumptions,
- timing exceptions,
- CDC-related constraints,
- validation commands.

Do not invent board, timing, schematic, or constraint information.
If intent is unclear, add TODO(constraint-doc) only when useful.

Project context:
VHDL VGA pattern generator for Basys 3 / Artix-7.
Possible top-level ports:
- clk_100mhz_i
- vga_hsync_o
- vga_vsync_o
- vga_red_o
- vga_green_o
- vga_blue_o

Return the updated XDC file and a short commenting summary.
```
