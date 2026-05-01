# XDC Practical Commenting Prompt

Use this shorter prompt for daily Codex work on one XDC file.

```text
ABSOLUTE COMMENT-ONLY MODE

Your task is documentation only.

You must not change any implementation or constraint line.
You must not add, remove, modify, reorder, uncomment, comment out, reformat, or replace any XDC constraint command.

Only Tcl/XDC comments using "#" may be added or improved.

Every existing non-comment XDC line must remain textually unchanged.

Task:
Add strict, review-grade comments to this XDC constraint file.

Commenting goals:
- Explain constraint intent, not just command syntax.
- Explain what the file constrains.
- Explain target board/device/top-level scope if clear.
- Explain clock assumptions.
- Explain physical pin mappings.
- Explain I/O standards.
- Explain generated clock or Clocking Wizard assumptions if present.
- Explain I/O delay decisions or missing I/O delay review notes if relevant.
- Explain timing exceptions if present.
- Explain CDC-related constraint intent if present.
- Use English comments only.
- Keep comments concise but useful for timing and design review.

Required documentation:
1. Add or update a file-level header with:
   - file name,
   - project name,
   - target board/device if known,
   - constraint type: timing / physical / debug / mixed,
   - source of truth: board schematic / master XDC / datasheet / project decision / unknown,
   - scope,
   - review notes,
   - validation commands.

2. Add section comments where useful:
   - Primary clocks,
   - Generated clocks,
   - Clock groups and CDC relationships,
   - Input timing constraints,
   - Output timing constraints,
   - Timing exceptions,
   - Physical pin constraints,
   - I/O standards,
   - Debug-only constraints.

Do not reorder existing commands.

3. For clock constraints, document:
   - source,
   - frequency,
   - period,
   - port/net/pin,
   - downstream usage,
   - validation method.

4. For pin/property groups, document:
   - board connector,
   - electrical standard,
   - RTL port group,
   - pin mapping source if clear,
   - review trigger.

5. For I/O delay constraints, document:
   - external interface,
   - reference clock,
   - min/max timing basis if clear,
   - validation report.

6. For timing exceptions, document:
   - exception type,
   - from/to scope,
   - reason if clear,
   - RTL structure that makes it safe if clear,
   - validation method,
   - risk if RTL changes.

Project context:
This is a VHDL VGA pattern generator project.
The board target may be Digilent Basys 3 with an AMD/Xilinx Artix-7 FPGA.
The top-level may expose:
- vga_hsync_o
- vga_vsync_o
- vga_red_o
- vga_green_o
- vga_blue_o
- clk_100mhz_i

A Clocking Wizard may generate a pixel clock from the 100 MHz board clock.

The design may intentionally leave simple VGA resistor-ladder outputs without set_output_delay if the external VGA interface is not modeled as a synchronous capture interface.

If constraint intent is unclear:
- do not guess,
- do not change the constraint,
- add TODO(constraint-doc) only if useful,
- mention uncertainty in the final summary.

Output:
1. Return the updated XDC file.
2. Add a short "Commenting summary" listing:
   - comments added or improved,
   - unclear constraint intent,
   - TODO(constraint-doc) items,
   - any suspicious issue noticed but not modified.
```
