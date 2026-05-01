# VHDL Review-Grade Commenting Master Prompt

Use this prompt for full review-grade documentation of VHDL RTL, packages, wrappers, or testbenches.

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


You are working on a VHDL FPGA project.

Your task is STRICTLY LIMITED to documentation comments.

ABSOLUTE NON-NEGOTIABLE RULE:
You must never, under any circumstances, change the implemented VHDL code.

This means:
- Do not change logic.
- Do not change behavior.
- Do not change timing.
- Do not change reset behavior.
- Do not change synthesis behavior.
- Do not change hierarchy.
- Do not rename anything.
- Do not change entity names.
- Do not change architecture names.
- Do not change package names.
- Do not change signal names.
- Do not change constant names.
- Do not change type names.
- Do not change generic names.
- Do not change port names.
- Do not change process labels.
- Do not change instance labels.
- Do not change function or procedure names.
- Do not change expressions.
- Do not change assignments.
- Do not change sensitivity lists.
- Do not change port maps.
- Do not change generic maps.
- Do not change library/use clauses.
- Do not change indentation or formatting of existing non-comment code.
- Do not reorder code.
- Do not add VHDL attributes, pragmas, assertions, constants, signals, aliases, functions, procedures, or logic.
- Do not fix bugs even if you notice them.
- Do not improve style by modifying code.

Allowed actions:
- Add VHDL comments using "--".
- Add structured block comments.
- Improve existing comments if they are stale, unclear, misleading, contradictory, or too weak.
- Add TODO(doc) comments only when the design intent is genuinely unclear.
- Add a short documentation summary after the file.

Critical preservation rule:
Every existing non-comment VHDL line must remain semantically and textually unchanged.
Only comment lines may be added or edited.

Commenting objective:
Add strict, review-grade documentation that helps a design reviewer understand:
- what the file implements,
- how it fits into the project,
- what hardware behavior it describes,
- what the interface means,
- which clock/reset assumptions apply,
- which signals are valid when,
- which constants/generics affect hardware structure,
- which parts are synthesis-relevant,
- which signals are intentionally unused,
- which parts require human review.

Use English comments only.

Do not write comments that merely restate the code.
Avoid comments such as:
- "increment counter"
- "assign signal"
- "set output"
- "check reset"
- "if rising edge"
unless the comment explains why the behavior matters.

Preferred VHDL documentation structure:

1. File-level header

Add or update a file-level header near the top of the file.

Use this structure when appropriate:

--==============================================================================
-- File        : <file name>
-- Project     : <project name>
-- Unit        : <entity/package/testbench name>
--
-- Description :
--   <Explain what this file implements.>
--
-- Project role:
--   <Explain how this file fits into the project hierarchy.>
--
-- Design level:
--   <RTL / package / testbench / wrapper / board-level top>
--
-- Clock/reset:
--   <Clock domain and reset assumptions, or "Not applicable" for packages.>
--
-- Synthesis:
--   <Synthesizable RTL / simulation-only / package / wrapper / vendor-specific>
--
-- Review notes:
--   <Important assumptions, limitations, or non-obvious design decisions.>
--==============================================================================

2. Entity/package header

Before each entity or package declaration, add or update a structured comment explaining:
- purpose,
- implemented behavior,
- interface groups,
- clock/reset assumptions,
- synthesis relevance,
- integration role.

For entities, document:
- whether the unit is combinational or clocked,
- latency if obvious from the code,
- valid/enable semantics,
- reset behavior,
- output semantics.

For packages, document:
- types,
- constants,
- helper functions,
- project-wide abstractions,
- intended users of the package.

3. Generics

Document generics when they affect:
- hardware structure,
- mode selection,
- timing,
- width calculation,
- coordinate range,
- counter range,
- synthesis decisions,
- interface compatibility.

Do not invent valid ranges unless they are obvious from the code.

4. Ports

Document ports when they represent:
- clocks,
- resets,
- enables,
- valid flags,
- sync signals,
- active-low or active-high signals,
- coordinate outputs,
- mode selects,
- pattern selects,
- CDC-related signals,
- external board-level I/O.

For each clock/reset port, clearly document:
- clock domain,
- reset polarity,
- synchronous/asynchronous behavior if clear from the code.

5. Processes

Before each non-trivial process, add a block comment describing:
- hardware behavior,
- clock domain,
- reset behavior,
- why the process exists,
- relevant review notes.

Do not describe only the syntax.

Good:
-- Registers RGB output in the pixel clock domain to align color changes with
-- pixel timing and avoid visible combinational glitches.

Bad:
-- Process triggered on rising edge of clock.

6. Functions and procedures

Before each non-trivial function or procedure, document:
- purpose,
- input meaning,
- returned value,
- assumptions,
- whether it is used for compile-time constants, synthesis logic, or simulation.

7. Generate blocks and component instances

Before each non-trivial generate block or component/entity instance, document:
- why it exists,
- what hardware/IP/module it represents,
- how it connects to the surrounding design,
- relevant clock/reset assumptions.

For vendor IP wrappers, document:
- IP role,
- input clock,
- output clock,
- reset/locked behavior,
- downstream modules using the generated signal.

8. Synthesis and tool-intent comments

Add comments where the design relies on:
- inferred registers,
- inferred RAM,
- inferred ROM,
- inferred DSP,
- vendor IP,
- clocking primitives,
- synchronizers,
- intentionally unused signals,
- linter-related design decisions.

Do not claim a resource is inferred unless it is clear from the code.

9. Intentionally unused signals

If a signal, generic, or port is intentionally unused because of a common interface, document it.

Example:
-- x_i and y_i are intentionally unused by this solid-color pattern.
-- They are kept to preserve the common pattern-generator interface.

10. Assertions and testbench code

For testbenches, document:
- verification intent,
- what behavior is checked,
- what is not checked,
- assumptions,
- expected pass/fail condition.

Do not add new assertions or tests.

Project-specific context:
- This project is a VHDL VGA pattern generator.
- The board target may be Basys 3 with an Artix-7 FPGA.
- Timing-related blocks may support:
  - VGA_640X480_60
  - SVGA_800X600_60
  - XGA_1024X768_60
- Distinguish clearly between:
  - active_video_o: visible video region including border,
  - video_on_o: addressable pattern-generation area only.
- Pattern blocks may share a common interface even when some inputs are intentionally unused.
- Solid-color patterns may intentionally ignore x_i and y_i.
- Checkerboard and ramp patterns depend on x/y coordinates and the addressable video area.
- Board-level wrapper code may instantiate a Clocking Wizard IP to generate a pixel clock from the board clock.

Uncertainty handling:
If the design intent is unclear:
- Do not guess.
- Do not change code.
- Add a concise TODO(doc) comment only if it is useful.
- Mention the uncertainty in the final documentation summary.

Output format:
1. Return the updated VHDL file content.
2. After the file, provide a short "Commenting summary" with:
   - Added or updated file-level comments,
   - Added or updated entity/package comments,
   - Added or updated process/function/instance comments,
   - Any existing comments improved,
   - Any TODO(doc) items,
   - Any unclear design intent.
```
