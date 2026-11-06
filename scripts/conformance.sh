#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

bin="${WEAVE_BIN:-}"
if [ -z "$bin" ]; then
  if [ -d "$root/../weave" ]; then
    (cd "$root/../weave" && go build -o "$work/weave" ./cmd/weave)
    bin="$work/weave"
  else
    bin="$(command -v weave)"
  fi
fi
"$bin" --version >/dev/null

bundle_a="$work/bundle-a"
bundle_b="$work/bundle-b"
mkdir -p "$bundle_a" "$bundle_b"
cat > "$bundle_a/note.md" <<'EOF'
---
type: Note
title: Token rotation
keywords:
  - tokens
  - security
---

Rotate API tokens every ninety days.
EOF
cat > "$bundle_b/runbook.md" <<'EOF'
---
type: Runbook
title: Incident runbook
keywords:
  - incidents
  - runbook
---

Follow the incident runbook.
EOF

workspace="$work/workspace"
"$bin" workspace init "$workspace" >/dev/null

"$bin" source add notes "$bundle_a" --workspace "$workspace" >/dev/null
"$bin" source list --workspace "$workspace" --json > "$work/list.json"
grep -q '"alias":"notes"' "$work/list.json"
grep -q '"status":"active"' "$work/list.json"

"$bin" source add runbooks "$bundle_b" --workspace "$workspace" >/dev/null
"$bin" ingest --workspace "$workspace" --json > "$work/ingest.json"
grep -q "\"db\":\"$workspace/.weave/index.db\"" "$work/ingest.json"
grep -q '"source":"notes"' "$work/ingest.json"
grep -q '"source":"runbooks"' "$work/ingest.json"

"$bin" sync --workspace "$workspace" --json > "$work/sync.json"
grep -q '"ok":true' "$work/sync.json"

{
  printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"conformance","version":"0"}}}'
  printf '%s\n' '{"jsonrpc":"2.0","method":"notifications/initialized"}'
  printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
  printf '%s\n' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"weave_sources","arguments":{}}}'
  printf '%s\n' '{"jsonrpc":"2.0","id":4,"method":"resources/read","params":{"uri":"weave://workspace/sources"}}'
} | "$bin" mcp --workspace "$workspace" --stdio > "$work/mcp.jsonl"
grep -q 'weave_sources' "$work/mcp.jsonl"
grep -q '"alias":"notes"' "$work/mcp.jsonl"
grep -q 'weave://workspace/sources' "$work/mcp.jsonl"

"$bin" source remove runbooks --workspace "$workspace" --prune >/dev/null
"$bin" source list --workspace "$workspace" --json > "$work/final.json"
if grep -q '"alias":"runbooks"' "$work/final.json"; then
  echo "runbooks source was not pruned" >&2
  exit 1
fi

echo "CONFORMANCE_OK"
