# Usage Guide for VHDL and XDC Commenting Prompts

This guide explains how to use the prompt set for documentation-only commenting of VHDL source files and XDC constraint files.

## Goal

The goal is to make the source files review-grade without changing the implementation.

The prompts are designed for a strict workflow where Codex may only add or improve comments. It must not modify VHDL logic, package contents, testbench behavior, or XDC constraint behavior.

## Files in this prompt set

| File | Purpose |
|---|---|
| `00_common_comment_only_guard.md` | Reusable safety block for comment-only mode |
| `01_vhdl_master_prompt.md` | Full strict prompt for VHDL files |
| `02_vhdl_practical_prompt.md` | Shorter daily-use prompt for VHDL files |
| `03_vhdl_quick_prompt.md` | Compact VHDL prompt when context is already clear |
| `04_xdc_master_prompt.md` | Full strict prompt for XDC files |
| `05_xdc_practical_prompt.md` | Shorter daily-use prompt for XDC files |
| `06_xdc_quick_prompt.md` | Compact XDC prompt when context is already clear |
| `07_comment_review_prompt.md` | Review prompt for checking generated comments |

## Recommended workflow

Use one file at a time.

1. Pick one VHDL or XDC file.
2. Choose the right prompt.
3. Paste the prompt into Codex.
4. Paste or point Codex to the target file.
5. Ask Codex to return the updated file.
6. Review the diff manually.
7. Reject any result where a non-comment line changed.
8. Commit only after verifying the change is documentation-only.

## Which prompt should you use?

| Situation | Recommended prompt |
|---|---|
| First documentation pass on an important RTL block | `01_vhdl_master_prompt.md` |
| Daily work on a single VHDL file | `02_vhdl_practical_prompt.md` |
| Fast pass on similar VHDL pattern modules | `03_vhdl_quick_prompt.md` |
| First documentation pass on an XDC file | `04_xdc_master_prompt.md` |
| Daily work on one XDC file | `05_xdc_practical_prompt.md` |
| Fast pass on simple XDC pinout comments | `06_xdc_quick_prompt.md` |
| Checking Codex-generated comments | `07_comment_review_prompt.md` |

## Strong rule: comments only

The most important rule is:

```text
Every existing non-comment line must remain textually unchanged.
```

For VHDL this means Codex must not change:
- logic,
- assignments,
- expressions,
- declarations,
- entity names,
- architecture names,
- package names,
- signal names,
- constants,
- types,
- generics,
- ports,
- process labels,
- instance labels,
- port maps,
- generic maps,
- library/use clauses,
- formatting of existing implementation lines.

For XDC this means Codex must not change:
- clock constraints,
- pin assignments,
- I/O standards,
- timing exceptions,
- input/output delays,
- clock groups,
- command order,
- command formatting,
- commented/uncommented state of constraints.

## Suggested Git workflow

Before running Codex:

```bash
git status
```

After Codex modifies one file:

```bash
git diff -- <file>
```

Review the diff carefully.

For VHDL, only lines starting with `--` should be added or edited.

For XDC, only lines starting with `#` should be added or edited.

If any non-comment line changed, reject or revert the change:

```bash
git restore -- <file>
```

When the result is clean, commit:

```bash
git add <file>
git commit -m "docs: add review-grade comments to <module-or-file>"
```

Examples:

```bash
git commit -m "docs: add review-grade comments to VGA timing RTL"
git commit -m "docs: document Basys3 VGA constraints"
```

## Recommended order for your VGA project

A good order for the `vga_pattern_generator` project would be:

1. `vga_timing_pkg.vhd`
2. `vga_timing_generator.vhd`
3. pattern package files
4. common pattern modules
5. solid-color pattern modules
6. checker/ramp/step pattern modules
7. pattern selector mux
8. Basys3 board-level wrapper
9. XDC physical constraints
10. XDC timing constraints
11. testbenches

This order helps Codex learn the project vocabulary from the central packages before documenting smaller modules.

## VHDL review checklist

After Codex comments a VHDL file, check:

- Did any non-comment line change?
- Is the file header accurate?
- Is the entity/package role described correctly?
- Are clock and reset assumptions correct?
- Are `active_video_o` and `video_on_o` semantics described correctly?
- Are valid coordinate assumptions documented correctly?
- Are intentionally unused signals documented without adding noise?
- Are process comments explaining hardware intent rather than syntax?
- Are comments too verbose?
- Are any comments speculative?
- Are any TODO(doc) items useful and actionable?

## XDC review checklist

After Codex comments an XDC file, check:

- Did any non-comment line change?
- Did any constraint command change?
- Were commands reordered?
- Did Codex invent board or schematic information?
- Are clock comments accurate?
- Are pin mapping comments accurate?
- Are I/O delay assumptions clearly marked?
- Are no_input_delay/no_output_delay decisions documented correctly?
- Are timing exceptions explained only when the reason is actually clear?
- Are TODO(constraint-doc) items useful and actionable?

## Handling uncertainty

Codex should not guess.

If the intent is unclear, the preferred output is:

For VHDL:

```vhdl
-- TODO(doc): Clarify why this signal is kept separate from <related_signal>.
```

For XDC:

```tcl
# TODO(constraint-doc): Explain why this timing exception is safe.
```

A TODO comment is acceptable only when it helps future review. It should not be used as filler.

## Recommended commit style

Use documentation-specific commit messages:

```text
docs: add review-grade comments to VGA timing package
docs: document checker pattern RTL intent
docs: document Basys3 physical constraints
docs: clarify VGA output timing assumptions
```

Avoid mixed commits that include both documentation and functional changes.

## Practical Codex prompt template

For VHDL:

```text
<contents of 00_common_comment_only_guard.md>

<contents of 02_vhdl_practical_prompt.md>

Here is the file:
```vhdl
<paste file here>
```
```

For XDC:

```text
<contents of 00_common_comment_only_guard.md>

<contents of 05_xdc_practical_prompt.md>

Here is the file:
```tcl
<paste file here>
```
```

## Best practice

Start with one important but not too large file. For example:

- `vga_timing_pkg.vhd`
- `vga_timing_generator.vhd`
- the Basys3 XDC file

Then review the output manually. After the style feels right, continue with the rest of the project.
