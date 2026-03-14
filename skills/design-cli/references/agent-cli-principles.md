# Agent CLI Principles

This reference is intentionally self-contained. It distills a practical design stance for agent-facing CLIs:

- Start from the broad environment the agent already has: shell, files, browser, and APIs.
- Do not rush to freeze every capability into a tool.
- Watch what gets repeated in real runs.
- Productize only the repeated, high-value, high-risk paths into commands.
- Keep the CLI narrow enough that it removes choices rather than reintroducing the whole product surface.

## Core Model

- Start with the raw workflow first. Let the operator use the terminal, browser, and file system before freezing anything into a tool.
- Observe desire paths: repeated actions, repeated errors, repeated lookups, repeated confirmations.
- Move only those stable paths into the CLI. Leave novel work to the shell or broader environment.
- Design the CLI as a constrained protocol, not as a mirror of backend resources.

## Common Misconceptions

- More tools do not automatically make an agent better. If the new command surface exposes the same complexity as the backend, the agent still has to rediscover the workflow every run.
- JSON is not automatically better than text. Use structured output only when another machine consumer needs it. Otherwise stable text is often easier for both humans and LLMs.
- Subagents are not a substitute for interface quality. If the workflow is unclear, adding more agents usually multiplies confusion.
- Rich internal state is not a product surface. Hidden sessions, invisible queues, and implicit defaults make agent behavior harder to inspect and recover.
- A CLI should not be a thin wrapper over every endpoint. It should encode intent, sequencing, defaults, and safety.

## Why CLI First Often Wins

- The terminal already gives composition, piping, files, history, retries, and inspection.
- Files are cheap, durable state. They are often better than forcing the agent to keep everything in context.
- Browser and shell access let you learn the workflow before inventing abstractions.
- A CLI can package the stable path while preserving an escape hatch for outliers.

## What to Productize

Promote a workflow into a command when most of these are true:

- The sequence repeats across tasks.
- The inputs and outputs are stable enough to name.
- The failure modes are predictable.
- The action is risky, expensive, or easy to misuse.
- The operator repeatedly needs the same check, diff, or confirmation.

Keep a workflow out of the CLI when it is still exploratory, highly custom, or dominated by one-off judgment calls.

## Command Surface

- Prefer a few high-signal verbs over many CRUD-shaped verbs.
- Make the common path short enough to fit in one help example.
- Keep advanced flags available but off the critical path.
- Use consistent nouns, flag names, and ordering across sibling commands.
- Favor intent over implementation detail.

Bad:
- `acme job create --type deploy --source spec.md --mode safe`

Better:
- `acme deploy plan spec.md`
- `acme deploy apply spec.md --dry-run`

Another reshape:

Bad:
- `acme artifact create --kind report --input run.json --destination out/ --overwrite true`

Better:
- `acme report build run.json --out out/report.md`
- `acme report check run.json`

## Desire-Path Patterns

- Put the main artifact in a positional argument when that mirrors how the operator thinks.
- Use flags for control, not for the whole payload.
- Accept stdin for generated content or streamed input.
- Print a path when the result is large or multi-file.
- Separate "inspect" from "mutate" commands.
- Make the reversible step easier than the irreversible step.

## Help Text

- Treat `--help` as part of the product surface.
- Open with one line that states the job clearly.
- Show examples before the full flag list.
- Tell the operator where output goes and what side effects happen.
- Make the safe path obvious.

Prefer this structure:

1. One-sentence purpose
2. Two to five common examples
3. Required inputs and defaults
4. Output and side-effect notes
5. Full option list

Avoid help text that only enumerates flags without teaching the operator how the command is supposed to be used.

## Errors and Exit Codes

- Send the main result to stdout and diagnostics to stderr.
- Return non-zero on failure.
- Write errors that tell the operator what to do next.
- Avoid vague failures such as "invalid request" when a concrete correction exists.
- Use distinct exit codes only when callers can act on the difference.

Good error pattern:

- What failed
- Why it likely failed
- What to try next

Example:

- `stderr: config file missing: ./deploy.yaml`
- `stderr: run 'acme deploy init' or pass --config <path>`
- exit `2`

## Text, JSON, and Files

- Default to stable plain text when humans or LLMs consume the output directly.
- Use JSON for machine-to-machine interchange, not as a reflex.
- When output is large, multi-file, or expensive to reprint, write artifacts to disk and print the path.
- Avoid mixing logs with the primary result on stdout.

Practical rule:

- stdout: primary result
- stderr: progress, warnings, diagnostics
- files: large artifacts, reports, patches, exports

If the command both explains and emits machine-consumable output, add a mode switch rather than mixing formats in one stream.

## Safety and State

- Add `plan`, `check`, or `diff` before `apply` when side effects matter.
- Add `--dry-run` for side-effecting commands.
- Require explicit confirmation flags for destructive actions.
- Make overwrites explicit.
- Prefer inspectable state in files or explicit status commands over hidden in-memory sessions.

Good safety defaults:

- No destructive action on plain invocation when a preview is possible
- Explicit `--yes` or `--force` for irreversible changes
- Stable artifact paths so operators can inspect before apply
- Idempotent re-runs where feasible

## Productization Loop

1. Start with browser/terminal access and broad freedom.
2. Watch real execution traces.
3. Capture the repeated high-value steps as a command.
4. Narrow the interface until it reduces decisions instead of adding them.
5. Keep an escape hatch for outliers.

This is the core loop:

- Explore broadly
- Observe repetition
- Freeze the repeated path
- Validate on real tasks
- Trim anything that leaks backend complexity back to the operator

## Anti-Patterns

- One command per backend endpoint
- Mandatory interactive prompts in automatable workflows
- Hidden defaults that materially change cost or side effects
- Huge inline outputs that should be written to files
- Logging, status chatter, and primary result all mixed on stdout
- A dozen equivalent flags that reveal internal implementation modes
- Help text that assumes prior tribal knowledge
- Commands that succeed with partial failure but never signal it in exit status

## Minimal Design Checklist

Before finalizing a CLI, verify:

- The happy path fits in a short example.
- The operator can tell where the result will appear.
- The operator can preview risky actions.
- Errors suggest a concrete recovery step.
- Non-interactive use works for automation and agents.
- State is inspectable.
- The command names reflect the job, not the database schema.

## Review Questions

- Does the command tree match user goals or backend tables?
- Can a new operator succeed from `--help` alone on the common path?
- Is the safe action easier than the dangerous action?
- Are stdout, stderr, files, and exit codes unambiguous?
- Is the command scriptable without hidden prompts?
- Did we add a command because it is repeated, or because the backend had an endpoint?
