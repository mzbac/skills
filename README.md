# Skills

This repo is a source of truth for my Codex skills.

## Layout

Skills live under `skills/<skill-name>/SKILL.md` (mirrors `openai/skills`).

## Install into Codex

Run inside Codex:

- `$skill-installer install https://github.com/mzbac/skills/tree/main/skills/code-review-low`
- `$skill-installer install https://github.com/mzbac/skills/tree/main/skills/diagram-first`
- `$skill-installer install https://github.com/mzbac/skills/tree/main/skills/planning-with-files`
- `$skill-installer install https://github.com/mzbac/skills/tree/main/skills/ask-questions-if-underspecified`

Or from a terminal (installs all in one command):

- `python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py --repo mzbac/skills --path skills/code-review-low skills/diagram-first skills/planning-with-files skills/ask-questions-if-underspecified`

## Sync from local Codex skills

- `./scripts/sync-from-codex-home.sh` (only updates existing skills in `./skills/`)
- `./scripts/sync-from-codex-home.sh --include-new` (also adds new skills from `~/.codex/skills/local`)

Restart Codex to pick up new skills.
