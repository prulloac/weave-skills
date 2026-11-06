# Workspace Reference

A workspace is a manifest plus one index database. It gives every bundle a stable alias.

## Manifest

`weave.workspace.yaml`:

```yaml
version: 1
index: ~/.weave/workspaces/project.db   # optional
sources:
  notes: ~/notes
  docs: ../project/docs
```

- `version` must be `1`.
- `index` defaults to `<manifest-dir>/.weave/index.db`.
- Relative source paths resolve against the manifest directory.
- `~` expands to the home directory.
- Aliases match `[a-z0-9][a-z0-9-]*`.
- `contract`, `weave` and `workspace` are reserved.
- Duplicate aliases or the same absolute path under two aliases are invalid.

## Commands

```sh
weave workspace init [<dir>]
weave workspace show [--workspace <dir>] [--json]
weave workspace path [--workspace <dir>]
weave source add <alias> <path> [--workspace <dir>]
weave source remove <alias> [--workspace <dir>] [--prune]
weave source list [--workspace <dir>] [--json]
weave source show <alias> [--workspace <dir>] [--json]
```

- Without `--workspace`, Weave searches the current directory and its ancestors for the manifest.
- `workspace init` never overwrites an existing manifest.
- `source add` writes the manifest, ingests the bundle and records the status.
- `source remove` unregisters the source and retains its index rows.
- `source remove --prune` also deletes those rows.

## Status

| Status | Meaning |
| --- | --- |
| `indexing` | First sync is not complete; not served |
| `active` | Indexed and served |
| `degraded` | A later sync failed; the last snapshot is still served |
| `removed` | Unregistered; data retained unless pruned |

## Manual edits

Editing the manifest does not re-index by itself:

```sh
$EDITOR ~/weave-workspace/weave.workspace.yaml
weave ingest --workspace ~/weave-workspace --json
```

A running `weave mcp --workspace <dir> --watch` reconciles manifest edits automatically.

## Multi-writer safety

Only one process writes the workspace index at a time. A second writer fails with `INDEX_LOCKED`.
Readers are unaffected. `source add` writes the manifest first, so a running watcher can index the
source on its next reconcile even if the command reports a lock warning.

## Validate before telling the user it worked

```sh
weave source list --workspace ~/weave-workspace --json
```

Inspect the `status` of every source. `active` is the only status that is fully served.
