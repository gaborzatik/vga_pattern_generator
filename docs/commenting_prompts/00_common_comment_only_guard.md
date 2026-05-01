# Common Comment-Only Guard Block

Use this guard block at the beginning of any Codex prompt when the task is documentation-only.

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
```
