# Claude Code statusline

Custom statusline for Claude Code, showing model, effort level, project/branch,
a color-coded context-usage bar, and 5h/7d rate-limit usage with local reset times.

## Setup

1. Copy `statusline.sh` to your Claude config directory, e.g. `~/.claude/statusline.sh`
   (or `~/.claude-personal/statusline.sh` if using a custom `CLAUDE_CONFIG_DIR`).
2. Make it executable: `chmod +x ~/.claude/statusline.sh`
3. Merge the `statusLine` block from `settings.snippet.json` into your
   `settings.json`, updating the `command` path to match where you placed the script.
4. Restart Claude Code.

Requires `jq` and `git` on `PATH`.
