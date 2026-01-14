#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync-from-codex-home.sh [--include-new]

Sync skill folders from $CODEX_HOME/skills/local into this repo's ./skills/.

By default, only syncs skills that already exist in ./skills/ to avoid accidentally
copying private/experimental skills into git. Use --include-new to add new skills.
EOF
}

include_new="false"
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi
if [[ "${1:-}" == "--include-new" ]]; then
  include_new="true"
  shift
fi
if [[ "${#}" -ne 0 ]]; then
  echo "Error: unexpected arguments: $*" >&2
  usage >&2
  exit 2
fi

CODEX_HOME="${CODEX_HOME:-"$HOME/.codex"}"
SOURCE_DIR="${CODEX_HOME}/skills/local"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="${REPO_ROOT}/skills"

display_source_dir="${SOURCE_DIR/#$HOME/~}"
display_dest_dir="./skills"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Source skills dir not found: ${display_source_dir}" >&2
  exit 1
fi

mkdir -p "${DEST_DIR}"

for skill_dir in "${SOURCE_DIR}"/*; do
  [[ -d "${skill_dir}" ]] || continue
  [[ -f "${skill_dir}/SKILL.md" ]] || continue

  skill_name="$(basename "${skill_dir}")"
  if [[ "${include_new}" != "true" && ! -d "${DEST_DIR}/${skill_name}" ]]; then
    echo "Skipping new skill '${skill_name}' (not present in repo). Use --include-new to include it."
    continue
  fi
  rsync -a --delete --exclude 'dist/' --exclude '*.skill' "${skill_dir}/" "${DEST_DIR}/${skill_name}/"
done

echo "Synced skills from ${display_source_dir} -> ${display_dest_dir}"
