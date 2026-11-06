# Query Reference

Use MCP when it is connected. Use CLI reads only when MCP is unavailable or the workspace is not
being served.

## MCP first

Start with `weave_sources`, then `weave_list` or `weave_search` to find a concept. Do not treat
`weave://bundle/index` as a concept catalog: it contains root `index.md` entries and is rejected in
workspace mode.

| Need | MCP tool |
| --- | --- |
| Discover sources | `weave_sources` |
| Search | `weave_search` |
| Explain a result | `weave_explain` |
| Read one concept | `weave_show` |
| List concepts | `weave_list` |
| Graph neighborhood | `weave_relate` |
| Incoming links | `weave_backlinks` |
| Shortest path | `weave_path` |
| Conformance report | `weave_audit` |
| Operations contract | `weave_contract` |

Call `weave_sources` first and use the returned aliases. Scope a call with `source`:

```json
{"name": "weave_search", "arguments": {"query": "token rotation", "source": "notes", "mode": "hybrid"}}
```

An unqualified target that exists in more than one source fails with `INVALID_REQUEST`. Qualify it
as `alias:id`.

## MCP resources

```text
weave://workspace/sources
weave://workspace/concepts
weave://workspace/stats
weave://source/<alias>/concept/<id>
weave://source/<alias>/bundle/index
weave://source/<alias>/bundle/stats
weave://blob/<id>
```

Use `weave://workspace/concepts` for discovery when a concept ID is unknown.

`weave_show` returns blob metadata and a URI; read the bytes through the blob resource.

## CLI reads

CLI reads take an explicit bundle path. Add `--source` for multiple roots:

```sh
weave search ~/notes --source docs=~/docs "token rotation" --mode hybrid --json
weave show ~/notes --source docs=~/docs docs:runbook --json
weave list ~/notes --source docs=~/docs --type Note --json
weave audit ~/notes --source docs=~/docs --json
```

There is no `weave search --workspace` shortcut. To query a workspace from the CLI, pass the manifest
sources explicitly or use MCP.

## Search modes

| Mode | Available |
| --- | --- |
| `keyword`, `fuzzy`, `hybrid`, `bm25` | CLI and MCP |
| `semantic` | CLI only; MCP does not expose it yet |

Semantic search needs an embedding-ready index:

```sh
weave search <bundle> "concept" --mode semantic --embedder ai --json
```

## Output

- CLI with `--json` returns one `weave.cli/v1` envelope.
- CLI without `--json` returns human output.
- MCP returns the same operation result payloads through `tools/call`, plus resources.

Read `ok`, `error.code` and the result dimensions before deciding what to tell the user.
