---
name: Weave CLI
description: Operate a Weave knowledge workspace with the CLI — create workspaces, add and remove bundles, ingest, sync, export and maintain embeddings — and route read-only search and retrieval to the Weave MCP server.
metadata:
  version: "0.1.0"
compatibility:
  weave: ">= 1.0.0"
  contract: "weave.contract/v1"
---

# Weave CLI

Use this skill when the user wants to add knowledge to Weave, connect an agent to a Weave workspace,
or maintain a Weave index.

## Core rule

**Reads go to MCP. Writes and lifecycle go to the CLI.**

- Use MCP tools for `weave_search`, `weave_explain`, `weave_relate`, `weave_audit`, `weave_list`,
  `weave_show`, `weave_backlinks`, `weave_path`, and resources.
- Use the CLI for `workspace`, `source`, `ingest`, `rebuild`, `sync`, `export`, `embeddings`,
  `config`, `codecs` and `extensions`.
- Never try to add a bundle through an MCP tool. MCP is read-only.

If no Weave MCP server is connected, use the CLI for reads too, with an explicit bundle path and
`--source` flags.

## Workflow: start a workspace

```sh
weave workspace init ~/weave-workspace
weave source add notes ~/notes --workspace ~/weave-workspace
weave source add docs ~/project/docs --workspace ~/weave-workspace
weave source list --workspace ~/weave-workspace
```

Continue with [references/workspace.md](references/workspace.md) for the manifest schema, aliases,
statuses and source removal.

## Workflow: add a bundle while the agent is running

```sh
weave source add research ~/research --workspace ~/weave-workspace
```

If `weave mcp --workspace ~/weave-workspace --watch` is running, it re-reads the manifest and indexes
the new source without a restart. Check progress with `weave source list`.

If the source is `indexing` or `degraded`, continue with
[references/ingest-sync.md](references/ingest-sync.md).

## Workflow: re-index the workspace

```sh
weave ingest --workspace ~/weave-workspace --json
weave sync --workspace ~/weave-workspace --json
weave rebuild --workspace ~/weave-workspace --json
```

Ingestion is permissive by default. Use `--strict` when invalid documents must fail the command.
Continue with [references/ingest-sync.md](references/ingest-sync.md).

## Workflow: query the workspace

Prefer MCP. Start with `weave_sources` to discover aliases, then scope a tool call:

```json
{"name": "weave_search", "arguments": {"query": "token rotation", "source": "notes", "mode": "hybrid"}}
```

CLI reads require an explicit bundle path; use MCP when a workspace is already served. Continue with
[references/query.md](references/query.md).

## Workflow: export or maintain

```sh
weave export ~/notes --out ~/backup --format raw --yes --json
weave embeddings audit --db ~/.weave/index.db --json
```

Continue with [references/export-maintenance.md](references/export-maintenance.md). Raw export writes
plaintext; encrypted export requires `--format encrypted --key-id <id>`. Confirm with the user before
writing either.

## Safety checklist

- Confirm before `weave source remove --prune`; it deletes the source's index rows.
- Confirm before raw or encrypted export; both write files outside the bundle.
- Use `--json` and inspect `ok`, `errors` and `warnings` before continuing.
- Do not invent flags. If a command is missing, check `weave help <command>`.
- Do not put API keys or tokens in commands, manifests or skill files.

## Failure recovery

| Code or status | Action |
| --- | --- |
| `WORKSPACE_NOT_FOUND` | Run `weave workspace init` or pass `--workspace` |
| `WORKSPACE_INVALID` | Fix duplicate aliases/paths or the manifest version |
| `SOURCE_NOT_FOUND` | Run `weave source list` and use an existing alias |
| `INDEX_LOCKED` | Another writer holds the index; wait for it to finish |
| `degraded` | Read the ingest report and re-run with the right mode |
| Empty keyword results | Documents need `type` and `keywords`; check the frontmatter |

Continue with [references/troubleshooting.md](references/troubleshooting.md).

## References

| File | Contents |
| --- | --- |
| [references/workspace.md](references/workspace.md) | Manifest, aliases, source commands, statuses |
| [references/ingest-sync.md](references/ingest-sync.md) | Ingest, rebuild, sync, watch, modes, reports |
| [references/query.md](references/query.md) | CLI reads, MCP mapping, source targeting |
| [references/export-maintenance.md](references/export-maintenance.md) | Export, embeddings, config, extensions |
| [references/troubleshooting.md](references/troubleshooting.md) | Error codes and recovery |
