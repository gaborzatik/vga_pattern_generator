# VHDL Quick Commenting Prompt

Use this compact version when Codex already has enough project context.

```text
Apply strict review-grade VHDL documentation comments to this file.

COMMENT-ONLY MODE:
Do not change any non-comment line.
Do not change logic, behavior, timing, reset behavior, hierarchy, names, formatting, ordering, declarations, assignments, expressions, port maps, generic maps, or library/use clauses.
Only add or improve "--" comments.

Add useful comments that explain:
- file purpose and project role,
- entity/package/testbench purpose,
- clock/reset assumptions,
- interface semantics,
- generics and ports,
- non-trivial processes/functions/generate blocks/instances,
- synthesis intent,
- intentionally unused signals,
- unclear design intent using TODO(doc).

Avoid obvious comments that merely restate the code.

Project context:
VHDL VGA pattern generator for Basys 3 / FPGA.
Important semantics:
- active_video_o = visible region including border.
- video_on_o = addressable pattern area only.
- pattern modules may have unused common-interface inputs by design.

Return the updated file and a short commenting summary.
```
