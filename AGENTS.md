# AGENTS.md

`weave-skills` owns the user-facing agent skills for operating Weave. It is a distribution
repository, not part of the Weave engine: skills consume the published CLI/envelope and MCP contracts
and never import Weave packages.

## Scope

- Put product agent skills, installers, compatibility metadata and conformance tests here.
- Keep contributor skills (spec, BDD, TDD, review, debugging) in `weave/.agents/skills/`.
- Keep specifications, ADRs and roadmap in `weave-docs/`.
- Do not add engine code, Go modules or database access to this repository.

## Layout

```text
skills/weave-cli/SKILL.md          entry point and routing rules
skills/weave-cli/references/       workflow references loaded on demand
skills/weave-cli/scripts/          optional skill-local helpers
install.sh                         user-level OpenCode installer (global or project)
install.ps1                        Windows PowerShell installer
scripts/check.sh                   skill layout, frontmatter and Markdown checks
scripts/conformance.sh             runs documented commands against a Weave binary
.github/workflows/ci.yml           Markdown checks plus CLI conformance
```

## Commands

- Check skills and Markdown: `./scripts/check.sh`
- Conformance against a binary: `WEAVE_BIN=/path/to/weave ./scripts/conformance.sh`
- Conformance against this workspace: `./scripts/conformance.sh` builds `../weave` when present
- Install for OpenCode globally: `./install.sh`
- Install into the current project: `./install.sh --project`

`scripts/check.sh` needs `npx` for Markdown lint. `scripts/conformance.sh` needs a Weave binary with
workspace support (current `main` or a release that includes it).

## Invariants

1. **Contract only:** use documented CLI commands, flags and envelope fields. Never import Weave,
   read engine internals or depend on repository layout.
2. **Reads go to MCP, writes go to the CLI.** Do not teach the agent to mutate a workspace through
   MCP tools.
3. **Examples are executable.** Every documented workflow should run under `scripts/conformance.sh`
   or be marked as illustrative.
4. **User-level install.** Installers never require `sudo` or administrator rights.
5. **No secrets.** Examples use environment variables or placeholders, never real keys or tokens.
6. **Compatibility is explicit.** Every skill declares the Weave version and contract it targets.
7. **One entry point.** Prefer the `weave-cli` skill plus references; split only for distinct
   triggers.

## Testing quirks

- Conformance uses temporary workspaces and bundles; it never touches `~/.weave/index.db`.
- `WEAVE_BIN` selects the binary. Without it, the script builds `../weave` if present and otherwise
  looks for `weave` on `PATH`.
- OpenCode derives a skill ID from the directory or filename, not from frontmatter `name`. Keep the
  directory lowercase kebab-case.
- OpenCode loads supporting files only when the skill reads them; keep `SKILL.md` short and move
  detail into `references/`.

## Change flow

1. Change CLI behavior in `weave` first.
2. Update the matching reference and examples here.
3. Bump the skill version and compatibility range when behavior or flags change.
4. Run `./scripts/check.sh` and `./scripts/conformance.sh`.

## Release

- Version this repository independently with semantic versions.
- A breaking flag or workflow change requires a major skill version; additive examples are minor.
- Publish skills by tag only after conformance passes against the pinned Weave release.
