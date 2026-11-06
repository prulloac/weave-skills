# Troubleshooting

## Errors

| Code | Meaning | Fix |
| --- | --- | --- |
| `WORKSPACE_NOT_FOUND` | No manifest found | Run `weave workspace init` or pass `--workspace` |
| `WORKSPACE_INVALID` | Bad version, duplicate alias/path | Fix `weave.workspace.yaml` |
| `INVALID_REQUEST` | Invalid alias, conflicting flags or ambiguous target | Use lowercase aliases; qualify `alias:id` |
| `SOURCE_NOT_FOUND` | Alias not registered | Run `weave source list` |
| `INDEX_LOCKED` | Another writer holds the index | Wait for the writer or stop it |
| `BUNDLE_NOT_INDEXED` | Sync target has no index rows | Run `weave ingest --workspace <dir>` |
| `CODE_NOT_FOUND` / `CODEC_UNAVAILABLE` | Missing codec extension | Install the matching `weave-codec-<name>` |
| `PERMISSION_DENIED` | Filesystem access | Check path permissions; do not use `sudo` installers |

## Source status

```sh
weave source list --workspace <dir> --json
```

- `indexing`: wait, or run `weave ingest --workspace <dir>`.
- `active`: ready.
- `degraded`: inspect the ingest report and re-run with the correct mode.
- `removed`: re-add with `weave source add`.

Recovery:

```sh
weave ingest --workspace <dir> --json
```

## Empty keyword results

Documents need frontmatter with `type` and `keywords`:

```markdown
---
type: Note
title: Token rotation
keywords:
  - tokens
  - security
---
```

Permissive ingestion keeps invalid documents as synthetic entries; they may not appear in keyword
search. Fix the frontmatter and re-ingest.

## MCP connection

- The server is read-only; do not look for ingest or source tools.
- `weave_sources` should list aliases. If it is empty, the manifest has no sources.
- Check that the agent launches the same binary and workspace path you tested.
- Diagnostics go to stderr; MCP stdout must remain newline-delimited JSON-RPC.
- On Windows with Weave in WSL, launch through `wsl.exe` with absolute WSL paths.
- A non-loopback TCP bind requires `--token`.

## Safe recovery order

1. `weave source list --workspace <dir> --json`
2. `weave ingest --workspace <dir> --json`
3. Inspect `errors`, `warnings` and `sources[]`
4. Retry the failed operation
5. If the index is locked, identify the other writer before removing anything
