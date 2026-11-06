# Ingest, Rebuild and Sync

These commands write the index. They are CLI-only; MCP never mutates a workspace.

## Commands

```sh
weave ingest  --workspace <dir> [flags]
weave rebuild --workspace <dir> [flags]
weave sync    --workspace <dir> [flags]
```

- `--workspace` accepts a directory or the manifest file.
- The manifest index is used unless `--db <file>` is explicit.
- Every registered source is processed with the multi-source report shape.

Single-source equivalents also work:

```sh
weave ingest ~/notes --db <file>
weave rebuild ~/notes --db <file>
weave sync ~/notes --db <file>
```

## Which command

| Need | Command |
| --- | --- |
| First load or add documents | `ingest` |
| Re-encode or fully re-index | `rebuild` |
| Apply changes by content hash | `sync` |
| Add a new source | `source add`, or edit the manifest and run `ingest` |

## Modes

Ingestion is permissive by default: invalid documents become synthetic documents with warnings.

```sh
weave ingest --workspace <dir> --permissive --json  # keep dirty docs, warn
weave ingest --workspace <dir> --strict --json      # fail on invalid docs
```

`source add` uses the default permissive mode. A degraded source usually means an unreadable or
invalid root, not simply missing frontmatter.

## Common flags

```sh
--codec zstd|none|<name>          body compression
--assets | --no-assets            include or drop blob documents
--asset-types <mime,...>          blob media types, for example image/png
--with-enricher <name>            enrich during the write
--with-embedder <name>            generate embeddings
--dry-run                         preview without writing
```

These apply to every source in a workspace write.

## Reports

Use `--json` and inspect:

- `ok` — command success;
- `errors` and `warnings` — aggregate counts;
- `sources[]` — per-source `source`, `documents`, `errors`, `warnings`.

After a successful workspace write, registry statuses are refreshed: zero errors per source becomes
`active`, otherwise `degraded`.

## Watching

```sh
weave mcp --workspace <dir> --watch --stdio
```

The server watches the manifest and active sources, indexes new sources and swaps them into the
served set without restart. `weave sync --watch` remains a single-bundle CLI mode and does not accept
`--workspace`.

## Single writer

`ingest`, `rebuild`, `sync --workspace`, `source add` and MCP reconciliation take an advisory lock
next to the index. A concurrent writer exits with `INDEX_LOCKED`.
