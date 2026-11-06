# Export and Maintenance

## Export

```sh
weave export <bundle> --out <dir> --format raw --yes --json
weave export <bundle> --out <dir> --format encrypted --key-id <id> --json
```

- `raw` writes plaintext document bodies.
- `encrypted` requires `--key-id`; use `--provider <name>` for an external crypto provider.
- `--force` is required for a non-empty target.
- `--dry-run` reports counts without writing.
- `--no-input` fails instead of prompting.

Always confirm with the user before exporting. Never print decrypted or exported bodies into the
conversation.

## Embeddings

```sh
weave embeddings list <bundle> --db <file> --json
weave embeddings rebuild <bundle> --model <model> --with-embedder ai --db <file> --json
weave embeddings drop <bundle> --model <model> --db <file> --json
weave embeddings drop <bundle> --model <model> --keep-source --db <file> --json
```

- `list` shows spaces and dimensions.
- `rebuild` re-embeds with a model and embedder.
- `drop` removes the space; `--keep-source` removes only the `vec0` index.
- `weave audit` reports `EMBEDDING_STALE` and `EMBEDDING_INDEX_MISMATCH`.

Embeddings are workspace-wide in practice: run the command once per bundle with the same database
when a workspace has several sources.

## Configuration

```sh
weave config show --json
weave config path
weave config init
```

Use configuration for machine paths and defaults. Use `weave.workspace.yaml` for source topology.

## Codecs and extensions

```sh
weave codecs list [<bundle>] --json
weave extensions list [<bundle>] --json
```

`weave-codec-<name>` extensions provide non-zstd codecs. `weave-<name>` extensions provide
enrichment, reranking, crypto and image support. Do not install extensions without the user's
consent.

## Audit before and after maintenance

```sh
weave audit <bundle> --source <alias>=<path> --fail-on warning --json
```

Use the report to find missing keywords, broken links, stale embeddings and missing codecs.
