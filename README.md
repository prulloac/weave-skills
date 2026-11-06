# Weave Agent Skills

Reusable instructions for agents that operate a Weave knowledge workspace.

Weave has two surfaces:

- **MCP** — read-only search, retrieval, graph and audit tools.
- **CLI** — workspace creation, bundle registration, ingest, sync, export and maintenance.

This repository teaches an agent when to use each, and gives it tested commands for the CLI-only
workflows.

## Skill

| Skill | Use it for |
| --- | --- |
| `weave-cli` | Creating workspaces, adding/removing bundles, indexing, syncing, exporting and maintaining embeddings; routing queries to MCP |

## Install

OpenCode discovers skills in `~/.config/opencode/skills`, `.opencode/skills`, `~/.agents/skills` and
`.agents/skills`. Copy the skill into one of them.

Global install (Unix/WSL):

```sh
./install.sh
```

Project install:

```sh
./install.sh --project
```

Windows PowerShell:

```powershell
.\install.ps1
.\install.ps1 -Project
```

Custom target:

```sh
./install.sh --target ~/shared/opencode-skills
```

Installers are user-level and never require `sudo` or administrator rights.

## Compatibility

The workspace workflows documented here require Weave `v1.0.0` or newer. The skill declares its
minimum Weave version and `weave.contract/v1` in `SKILL.md`.

For development builds:

```sh
go install github.com/prulloac/weave/cmd/weave@main
```

## Safety

The skill keeps the MCP server read-only:

- searches, shows, graph traversal and audits use MCP tools;
- workspace and source changes use the CLI;
- destructive actions such as `weave source remove --prune` and encrypted export require explicit
  user confirmation.

## Development

```sh
./scripts/check.sh
WEAVE_BIN=weave ./scripts/conformance.sh
```

`scripts/check.sh` validates skill layout, frontmatter and Markdown. `scripts/conformance.sh` creates
a temporary workspace and exercises the documented commands, including the MCP stdio handshake.

## Related

- [Weave CLI](https://github.com/prulloac/weave)
- [Workspace and MCP user guide](https://github.com/prulloac/weave/blob/main/docs/guides/workspace-mcp.md)
- [Workspace and Source Registry specification](https://github.com/prulloac/weave-docs/blob/main/specs/workspace.md)
- [Agent skills decision](https://github.com/prulloac/weave-docs/blob/main/architecture/adr/0008-agent-skills-standalone-distribution.md)
