# Comment Review Prompt

Use this prompt to review comments that Codex has already generated. This prompt should not modify the file.

```text
Review this commented VHDL or XDC file.

Do not modify the file.
Do not rewrite the file.
Do not generate a patched version.
Return review notes only.

Check whether the comments are:
- technically accurate,
- consistent with the code or constraints,
- not speculative,
- not misleading,
- not stale,
- not too verbose,
- not merely restating syntax,
- useful for design review,
- useful for timing or constraint review when applicable.

Also check whether Codex violated comment-only mode by changing any non-comment line, if a diff is available.

For VHDL, pay special attention to:
- clock/reset descriptions,
- valid signal semantics,
- active_video_o vs video_on_o semantics,
- synthesis-intent comments,
- intentionally unused signals,
- process/function comments.

For XDC, pay special attention to:
- clock constraint descriptions,
- pin mapping comments,
- I/O delay assumptions,
- timing exception comments,
- CDC comments,
- any claim about board schematics or timing budgets.

Output:
Return a concise review report with:
1. Comments that look correct and useful.
2. Comments that are misleading or too speculative.
3. Comments that are too obvious and should be removed.
4. Missing high-value comments.
5. Any non-comment modifications detected.
6. Recommended next action.
```
