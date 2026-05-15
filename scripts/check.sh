#!/usr/bin/env bash
# Smoke validator for this docs/learning repo.
#
# Verifies that:
#   1. Every tracked .json file is valid JSON.
#   2. Every tracked .yaml/.yml file is valid YAML (requires pyyaml; degrades
#      gracefully with a note if pyyaml is absent).
#   3. Every tracked .py file compiles.
#   4. Docs do not reference paths that no longer exist
#      (best-effort; only checks references/, assets/, scripts/ relative paths
#       inside SKILL.md files, ignoring skill-creator examples).
#   5. scripts/known-gaps.txt only lists paths that are still missing.
#
# Requirements:
#   - python3
#   - pyyaml (optional, for step 2): pip install pyyaml
#
# Usage: bash scripts/check.sh
#
# This script is read-only. It does not modify any files.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

fail=0

note() { printf '  %s\n' "$*"; }
ok()   { printf 'OK   %s\n' "$*"; }
bad()  { printf 'FAIL %s\n' "$*"; fail=1; }

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found; skipping all checks." >&2
  exit 2
fi

echo "==> JSON syntax"
while IFS= read -r f; do
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then
    ok "$f"
  else
    bad "$f"
  fi
done < <(git ls-files '*.json')

echo "==> YAML syntax"
if python3 -c "import yaml" 2>/dev/null; then
  while IFS= read -r f; do
    if python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$f" 2>/dev/null; then
      ok "$f"
    else
      bad "$f"
    fi
  done < <(git ls-files '*.yaml' '*.yml')
else
  note "pyyaml not installed; skipping YAML check."
fi

echo "==> Python compile"
# compileall returns non-zero only on failure; collect tracked .py files.
py_files=$(git ls-files '*.py')
if [ -n "$py_files" ]; then
  # Run py_compile letting stderr through, so a failure tells you which file.
  # shellcheck disable=SC2086  # intentional word-splitting on $py_files
  if python3 -m py_compile $py_files; then
    ok "$(echo "$py_files" | wc -l | tr -d ' ') file(s) compiled"
  else
    bad "py_compile error in tracked .py files (see stderr above)"
  fi
else
  note "no .py files tracked"
fi

echo "==> Docs reference paths (best-effort)"
# Inside any SKILL.md, look for relative paths like references/X, assets/X, scripts/X
# and confirm the file exists. Skip skill-creator (it documents hypothetical examples).
#
# Known-missing references (binary assets/scripts not mirrored from upstream)
# are listed in scripts/known-gaps.txt and reported as WARN, not FAIL.
known_gaps_file="$REPO_ROOT/scripts/known-gaps.txt"
is_known_gap() {
  [ -f "$known_gaps_file" ] || return 1
  grep -Fxq "$1" "$known_gaps_file"
}

while IFS= read -r skill; do
  case "$skill" in
    *skill-creator/SKILL.md) continue ;;
  esac
  dir=$(dirname "$skill")
  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    target="$dir/$rel"
    if [ ! -e "$target" ]; then
      if is_known_gap "$target"; then
        printf 'WARN %s -> missing %s (known gap)\n' "$skill" "$target"
      else
        bad "$skill -> missing $target"
      fi
    fi
  done < <(grep -oE '(references|assets|scripts)/[a-zA-Z0-9_./-]+\.(md|py|txt|pptx|xlsx|png|json|yaml)' "$skill" | sort -u)
done < <(git ls-files '*SKILL.md')

echo "==> known-gaps.txt freshness"
# A "known gap" should still be missing. If a listed path now exists,
# remove it from known-gaps.txt to keep the WARN list honest.
if [ -f "$known_gaps_file" ]; then
  while IFS= read -r gap; do
    case "$gap" in
      ''|'#'*) continue ;;
    esac
    if [ -e "$gap" ]; then
      printf 'WARN stale entry in known-gaps.txt: %s now exists\n' "$gap"
    fi
  done < "$known_gaps_file"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "All checks passed."
  exit 0
else
  echo "One or more checks failed."
  exit 1
fi
