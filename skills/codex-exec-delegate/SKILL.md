---
name: "codex-exec-delegate"
description: "Delegate coding tasks to a nested Codex CLI run using `codex exec --yolo -m gpt-5.3-codex -c model_reasoning_effort=xhigh`. Use when you want the current Codex agent to act as an orchestrator (plan/review/verify) while a separate worker session performs edits and runs tests."
---

# Codex Exec Delegate

## Workflow

1. Draft a `[CODEX TASK]` packet (goal, constraints, files, validation, done criteria).
2. Run a nested `codex exec` worker with `gpt-5.3-codex` + `model_reasoning_effort=xhigh`.
3. Verify independently with `git status`, `git diff`, and the validation commands from the packet.
4. If anything fails, re-run the worker with the failure output + a tightened packet.

## Worker Command

Prefer stdin to avoid shell quoting issues:

```bash
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

cat <<'PROMPT' | codex exec -C "$REPO_ROOT" --yolo -m "gpt-5.3-codex" -c "model_reasoning_effort=xhigh" -
[CODEX TASK]
...
PROMPT
```

## Packet Template

```text
[CODEX TASK]
Goal:
Constraints:
Files to inspect:
Files allowed to edit:
Validation commands:
Definition of done:

Required output:
1) Changed files
2) Summary of changes
3) Commands/tests run + results
4) Remaining risks
```

## Guardrails

- Include in the worker prompt: "Do not run `codex` or spawn sub-agents; implement directly."
- Keep scope minimal; avoid unrelated refactors.
- Never fabricate command output or test results.
