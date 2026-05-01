# VHDL Practical Commenting Prompt

Use this shorter prompt for daily Codex work on one VHDL file.

```text
ABSOLUTE COMMENT-ONLY MODE

Your task is documentation only.

You must not change any implementation line.
You must not change code, logic, behavior, timing, reset behavior, hierarchy, names, formatting, ordering, expressions, assignments, port maps, generic maps, library/use clauses, or declarations.

Only VHDL comments using "--" may be added or improved.

Every existing non-comment VHDL line must remain textually unchanged.

Task:
Add strict, review-grade comments to this VHDL file.

Commenting goals:
- Explain design intent, not obvious syntax.
- Explain what the file implements.
- Explain the role of the entity/package/testbench in the project.
- Explain clock domains, reset behavior, valid signal semantics, polarity, synthesis intent, and interface assumptions.
- Explain non-obvious constants, generics, ports, functions, processes, generate blocks, and component/entity instances.
- Document intentionally unused signals if they are part of a common interface.
- Use English comments only.
- Keep comments concise but useful for code review.

Required documentation:
1. Add or update a file-level header with:
   - file name,
   - project name,
   - unit name,
   - short description,
   - project role,
   - design level: RTL / package / testbench / wrapper / board top,
   - clock/reset assumptions,
   - synthesis or simulation classification,
   - review notes.

2. Add or update entity/package comments explaining:
   - purpose,
   - behavior,
   - interface groups,
   - clock/reset assumptions,
   - integration role.

3. Add comments for important generics and ports, especially:
   - clocks,
   - resets,
   - enables,
   - valid flags,
   - sync signals,
   - coordinates,
   - mode selects,
   - pattern selects,
   - width-related generics,
   - CDC-related signals.

4. Add block comments before non-trivial:
   - processes,
   - functions,
   - procedures,
   - generate blocks,
   - component/entity instances,
   - state machines,
   - synchronizers,
   - output registers.

5. Add inline comments only when they clarify non-obvious design intent.

Avoid useless comments such as:
- "increment counter"
- "assign signal"
- "set output"
- "check reset"
- "rising edge"

Project context:
This is a VHDL VGA pattern generator project.
Timing-related blocks may support:
- VGA_640X480_60
- SVGA_800X600_60
- XGA_1024X768_60

Important project semantics:
- active_video_o means visible video region including border.
- video_on_o means addressable pattern-generation area only.
- Pattern blocks may share a common interface even when some inputs are intentionally unused.
- Solid-color patterns may intentionally ignore x_i and y_i.
- Checkerboard and ramp patterns depend on x/y coordinates.
- A Basys 3 wrapper may instantiate a Clocking Wizard to generate a pixel clock from the board clock.

If intent is unclear:
- do not guess,
- do not change code,
- add TODO(doc) only if useful,
- mention uncertainty in the final summary.

Output:
1. Return the updated VHDL file.
2. Add a short "Commenting summary" listing:
   - comments added or improved,
   - unclear design intent,
   - TODO(doc) items,
   - any suspicious issue noticed but not modified.
```
