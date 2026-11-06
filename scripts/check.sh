#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

fail=0
seen=""
while IFS= read -r skill; do
  id="$(basename "$(dirname "$skill")")"
  if [ -n "$(printf '%s\n' "$seen" | grep -x "$id" || true)" ]; then
    echo "duplicate skill id: $id" >&2
    fail=1
  fi
  seen="$seen$id"$'\n'

  if [ "$(head -n 1 "$skill")" != "---" ]; then
    echo "$skill: missing frontmatter" >&2
    fail=1
  fi
  for field in name description compatibility; do
    if ! grep -q "^$field:" "$skill"; then
      echo "$skill: missing $field" >&2
      fail=1
    fi
  done

  dir="$(dirname "$skill")"
  while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    if [ ! -f "$dir/$ref" ]; then
      echo "$skill: missing $ref" >&2
      fail=1
    fi
  done < <(grep -o 'references/[a-z0-9-]*\.md' "$skill" | sort -u || true)
done < <(find skills -name SKILL.md | sort)

bash -n install.sh

if command -v npx >/dev/null 2>&1; then
  npx --yes markdownlint-cli2 "**/*.md"
else
  echo "warning: npx not found; skipped Markdown lint" >&2
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "CHECK_OK"
