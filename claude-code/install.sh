#!/usr/bin/env bash
# Installs this Claude Code config into a target profile directory.
# Usage: ./install.sh [target-dir]
#   target-dir defaults to $CLAUDE_CONFIG_DIR, or ~/.claude if unset.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${1:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"

mkdir -p "$target"
cp "$src/statusline.sh" "$target/statusline.sh"
chmod +x "$target/statusline.sh"

mkdir -p "$target/sounds"
cp "$src/sounds/"* "$target/sounds/"

mkdir -p "$target/skills"
cp -R "$src/skills/." "$target/skills/"

if [ -f "$target/settings.json" ]; then
  echo "settings.json already exists at $target — not overwriting."
  echo "Merge $src/settings.json into it manually."
else
  cp "$src/settings.json" "$target/settings.json"
  echo "Installed settings.json to $target"
fi

echo "Done. Restart Claude Code to pick up the new config."
echo "If \$target is not ~/.claude, remember to export CLAUDE_CONFIG_DIR=$target in your shell profile."
