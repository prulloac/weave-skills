#!/usr/bin/env bash
set -eu

usage() {
  cat <<'EOF'
Install Weave agent skills for OpenCode.

Usage: install.sh [options]

Options:
  --global          Install to ~/.config/opencode/skills (default)
  --project         Install to ./.opencode/skills
  --target <dir>    Install to a custom skills directory
  -h, --help        Show this help

The installer is user-level and never uses sudo.
EOF
}

mode="global"
target=""
while [ $# -gt 0 ]; do
  case "$1" in
    --global)
      mode="global"
      shift
      ;;
    --project)
      mode="project"
      shift
      ;;
    --target)
      [ $# -ge 2 ] || { echo "install: --target requires a directory" >&2; exit 1; }
      target="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "install: unknown option: $1" >&2
      exit 1
      ;;
  esac
done

root="$(cd "$(dirname "$0")" && pwd)"
if [ -z "$target" ]; then
  if [ "$mode" = "project" ]; then
    target="$PWD/.opencode/skills"
  else
    target="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"
  fi
fi

mkdir -p "$target"
cp -R "$root/skills/weave-cli" "$target/"
echo "Installed weave-cli to $target/weave-cli"
echo "Reload OpenCode or run /reload if the skill does not appear."
