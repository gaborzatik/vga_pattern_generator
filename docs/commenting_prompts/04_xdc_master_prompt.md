# XDC Review-Grade Commenting Master Prompt

Use this prompt for full review-grade documentation of XDC constraint files.

```text

ABSOLUTE COMMENT-ONLY MODE

Your task is documentation only.

You must not change any implementation line.
You must not change code, logic, behavior, timing, reset behavior, hierarchy, names, formatting, ordering, expressions, constraints, declarations, assignments, port maps, generic maps, library/use clauses, or constraint commands.

Only comments may be added or improved.

Every existing non-comment line must remain textually unchanged.

If you notice a bug, suspicious construct, bad style, missing reset, timing issue, questionable constraint, or possible improvement:
- do not fix it,
- do not modify the implementation,
- document only if useful,
- mention it in the final summary.

You are working on an FPGA XDC constraint file.

Your task is STRICTLY LIMITED to documentation comments.

ABSOLUTE NON-NEGOTIABLE RULE:
You must never, under any circumstances, change the implemented constraint behavior.

This means:
- Do not add constraint commands.
- Do not remove constraint commands.
- Do not modify constraint commands.
- Do not change clock periods.
- Do not change clock names.
- Do not change port names.
- Do not change pin assignments.
- Do not change IOSTANDARD assignments.
- Do not change PACKAGE_PIN assignments.
- Do not change create_clock commands.
- Do not change create_generated_clock commands.
- Do not change set_input_delay commands.
- Do not change set_output_delay commands.
- Do not change set_false_path commands.
- Do not change set_multicycle_path commands.
- Do not change set_clock_groups commands.
- Do not change set_property commands.
- Do not comment out active constraints.
- Do not uncomment inactive constraints.
- Do not reorder constraints.
- Do not reformat existing constraint commands.
- Do not replace constraints with better constraints.
- Do not fix constraints even if they appear wrong.
- Do not invent board, timing, or schematic information.

Allowed actions:
- Add Tcl/XDC comments using "#".
- Add structured section comments.
- Improve existing comments if they are stale, unclear, misleading, or too weak.
- Add TODO(constraint-doc) comments only when the constraint intent is genuinely unclear.
- Add a short documentation summary after the file.

Critical preservation rule:
Every existing non-comment XDC command line must remain semantically and textually unchanged.
Only comment lines may be added or edited.

Commenting objective:
Add strict, review-grade documentation that helps a design reviewer or timing reviewer understand:
- what the constraint file is for,
- which board/device/top-level it targets,
- what each constraint section means,
- where pin mappings come from,
- what each clock represents,
- what timing assumptions are being made,
- whether I/O delay warnings are accepted or unresolved,
- what timing exceptions mean,
- what must be re-reviewed if the RTL or board changes.

Use English comments only.

Do not write comments that merely restate the command.
Avoid comments such as:
# Set pin G19
unless the comment explains board-level or review intent.

Preferred XDC documentation structure:

1. File-level header

Add or update a file-level header at the top of the file.

Use this structure when appropriate:

#===============================================================================
# File        : <file name>.xdc
# Project     : <project name>
# Target      : <board and FPGA device if known>
#
# Constraint type:
#   <Physical / timing / debug / mixed>
#
# Source of truth:
#   <Board schematic / board master XDC / datasheet / project timing decision /
#    unknown if not clear from the file>
#
# Scope:
#   <Top-level entity or project this file applies to.>
#
# Review notes:
#   <Important assumptions, limitations, or review triggers.>
#
# Validation:
#   <Recommended Vivado reports, e.g. report_io, report_clocks,
#    check_timing -verbose, report_timing_summary.>
#===============================================================================

2. Section structure

Add section headers when appropriate, but do not reorder existing commands.

Preferred section names:
- Primary clocks
- Generated clocks
- Clock groups and CDC relationships
- Input timing constraints
- Output timing constraints
- Timing exceptions
- Physical pin constraints
- I/O standards
- Debug-only constraints
- Unconstrained or intentionally unconstrained interfaces

3. Clock constraints

Before each clock-related section, document:
- clock source,
- frequency,
- period,
- port/net/pin,
- downstream usage,
- validation method.

Example:

# Primary system clock.
#   Source     : Basys 3 on-board oscillator
#   Frequency  : 100 MHz
#   Period     : 10.000 ns
#   Feeds      : Clocking Wizard input and board-level synchronous logic
#   Validate   : report_clocks
create_clock -period 10.000 -name sys_clk_100mhz [get_ports clk_100mhz_i]

Do not change the clock command.

4. Generated clocks and Clocking Wizard

If the file references generated clocks or Clocking Wizard outputs, document:
- source clock,
- generated clock purpose,
- expected downstream domain,
- whether the generated clock appears explicit or tool-derived,
- need to verify using report_clocks.

Do not add create_generated_clock unless explicitly instructed.

If the generated clock target is unclear, add:
# TODO(constraint-doc): Verify the synthesized Clocking Wizard output clock name
# before documenting or constraining this generated clock further.

5. Physical pin constraints

For pin groups, document:
- board connector,
- electrical standard,
- RTL port group,
- source of pin mapping if known,
- review trigger.

Example:

# VGA red channel.
#   Board connector : Basys 3 VGA connector
#   Electrical      : 3.3 V LVCMOS resistor-ladder DAC
#   RTL ports       : vga_red_o[3:0]
#   Review trigger  : Re-check this mapping if the board top-level ports change.
set_property PACKAGE_PIN G19 [get_ports {vga_red_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_o[0]}]

Do not change the pin assignment.

6. I/O delay constraints

If set_input_delay or set_output_delay commands exist, document:
- external device/interface,
- reference clock,
- min/max timing basis if clear,
- validation report.

If no I/O delay constraints exist but the file clearly targets simple board-level VGA outputs, document the review decision carefully without modifying constraints.

Example:

# VGA outputs are not modeled with set_output_delay in this educational design.
# Reason:
#   The resistor-ladder VGA interface is not treated as a synchronous external
#   capture interface in the current timing model.
#
# Review note:
#   Vivado may report no_output_delay for these ports. This must be reviewed if
#   the design is extended to a synchronous external video interface.

7. Timing exceptions

For any timing exception, add a strict review-grade comment explaining:
- exception type,
- from/to scope,
- reason default static timing analysis does not apply,
- RTL structure that makes the exception safe,
- validation method,
- risk if RTL changes.

Do not add, remove, broaden, or narrow exceptions.

Example:

# Timing exception: <short name>
#   Type        : set_false_path
#   From        : <existing source expression>
#   To          : <existing destination expression>
#   Reason      : <document only if clear from context>
#   RTL support : <synchronizer/FIFO/static config path/etc., if clear>
#   Validation  : report_exceptions, check_timing, CDC review
#   Risk        : Re-review if the source or destination logic changes.
set_false_path ...

If the reason is unclear, do not guess.
Add:
# TODO(constraint-doc): Explain why this timing exception is safe.

8. CDC-related constraints

For CDC-related constraints, document:
- source clock domain,
- destination clock domain,
- synchronization structure if clear,
- why this constraint strategy is used,
- validation method.

Do not create new CDC constraints.

9. Debug constraints

For MARK_DEBUG, ILA, VIO, or debug-only properties, document:
- debug purpose,
- whether the constraint is intended for production or lab builds,
- removal/review condition.

Do not remove debug constraints.

Project-specific context:
- This project is a VHDL VGA pattern generator.
- The board target may be Digilent Basys 3 with an AMD/Xilinx Artix-7 FPGA.
- The top-level may expose VGA signals:
  - vga_hsync_o
  - vga_vsync_o
  - vga_red_o
  - vga_green_o
  - vga_blue_o
- A Clocking Wizard may generate a pixel clock from the 100 MHz board clock.
- Supported video modes may include:
  - VGA_640X480_60
  - SVGA_800X600_60
  - XGA_1024X768_60
- The design may intentionally leave simple VGA outputs without set_output_delay if the external VGA interface is not modeled as a synchronous capture interface.
- Any no_input_delay or no_output_delay warning must be documented as either:
  - intentionally accepted for this project stage, or
  - unresolved and requiring timing review.

Uncertainty handling:
If the constraint intent is unclear:
- Do not guess.
- Do not change the constraint.
- Add a concise TODO(constraint-doc) comment only if useful.
- Mention the uncertainty in the final documentation summary.

Output format:
1. Return the updated XDC file content.
2. After the file, provide a short "Commenting summary" with:
   - Added or updated file-level comments,
   - Added or updated section comments,
   - Added or updated clock comments,
   - Added or updated pin/physical constraint comments,
   - Added or updated timing exception comments,
   - Any TODO(constraint-doc) items,
   - Any unclear or risky constraint intent.
```
