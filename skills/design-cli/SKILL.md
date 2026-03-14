---
name: design-cli
description: Design or review agent-friendly command-line interfaces for tools, wrappers, and internal platforms. Use when Codex needs to create a new CLI, simplify an existing one, map real workflows to commands and flags, improve `--help` and error behavior, define stdout/stderr and file output contracts, add safety rails for destructive actions, or turn an API/service/browser workflow into a shell-first interface that humans and agents can drive reliably.
---

# Design CLI

Design the interface around the operator's real work, not the system's internal nouns.

Start from repeated tasks, decisions, artifacts, and risks. Create the smallest command surface that makes those paths obvious and safe, then leave an escape hatch to the shell, files, or existing tools for everything else.

## Default Deliverable

Unless the user asks for code only, work through these outputs:

1. Operator model: who runs the command and what success looks like
2. Proposed command surface: verbs, nouns, flags, stdin/files, examples
3. Help contract: what `--help` teaches on the happy path
4. Output contract: stdout, stderr, exit codes, files, JSON if needed
5. Safety model: dry run, confirmation, overwrite, rollback
6. Implementation notes: parser changes, tests, docs/help updates

If the user asks for implementation, turn the design into code and tests in the repo's existing CLI framework.

## Workflow

### 1. Model the job

- Name the operator: human, agent, automation, or mixed.
- State the desire path as a short sentence: "take X and produce Y safely."
- Separate control inputs from payloads:
  - Use flags for control knobs.
  - Use stdin or files for larger content.
  - Use stdout for the primary result.
  - Use stderr for progress and diagnostics.
- Identify irreversible or high-cost actions early.

### 2. Choose the command shape

- Prefer a few obvious verbs over a tree that mirrors backend tables or REST endpoints.
- Keep the happy path short. Push rare configuration into flags or deeper subcommands.
- Use names that describe intent, such as `plan`, `check`, `diff`, `apply`, `cancel`, `resume`, or `export`.
- Support non-interactive execution when the workflow will be agent-driven.
- Keep naming and flag semantics consistent across sibling commands.
- Do not map internal nouns 1:1 into commands unless they already match operator language.

### 3. Design progressive help

- Make the first help line say exactly what the command does.
- Show 3-5 copy/pasteable examples before the exhaustive flag list.
- Put required inputs, defaults, and file/output behavior near the top.
- Make `--help` sufficient for the common path.

### 4. Make errors corrective

- Print failures to `stderr`.
- Include what failed, why it likely failed, and the exact next step to recover.
- Use non-zero exit codes for failures. Split user error from system error when that distinction matters.
- Do not hide failure inside conversational prose while still exiting `0`.

### 5. Design the output contract

- Use stable plain text by default when humans or LLMs will read the result directly.
- Use JSON only when structured interchange is actually needed.
- For large outputs, write files and print a short summary plus the artifact path.
- Keep stdout parseable. Do not mix logs, banners, and primary results.
- Add quiet or verbose modes only when they solve a real problem.

### 6. Add safety rails

- Prefer `check`, `diff`, or `plan` before `apply`.
- Add `--dry-run` for commands with side effects.
- Require explicit confirmation flags for destructive or high-cost actions.
- Make overwrite or replace behavior explicit.
- Expose undo or rollback directly when feasible.

### 7. Iterate from real use

- Start with terminal, browser, and file-system workflows when the domain is still fuzzy.
- Watch what the operator repeats, where it hesitates, and what it gets wrong.
- Convert only the stable repeated patterns into CLI affordances.
- Keep the CLI narrow enough that it reduces choices instead of recreating the whole product surface.

## Review Heuristics

When reviewing an existing CLI, look for:

- Backend-shaped command trees that do not match user intent
- Help text that lists flags but does not teach the happy path
- Commands that interleave logs and results on stdout
- Errors that lack a concrete fix
- Missing `--dry-run`, confirmation, or idempotency
- Large blobs printed inline instead of saved to files
- Interactive prompts in workflows that should be scriptable
- State hidden in memory instead of inspectable files or commands

## Implementation Notes

- Match the repo's existing CLI library and help conventions.
- Update parser definitions, help text/examples, and tests together.
- Add tests for help text, exit codes, stdout/stderr separation, dry-run behavior, and destructive confirmation paths.

## Use the Reference

Read [agent-cli-principles.md](references/agent-cli-principles.md) when you need a deeper checklist, example command reshapes, or source-derived guidance on help, errors, output, and iterative CLI design.
