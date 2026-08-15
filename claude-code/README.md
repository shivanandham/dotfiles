# Claude Code config

Personal Claude Code setup: settings, hooks, statusline, sounds, and skills.
Meant to be dropped into a fresh machine to reproduce the same setup.

## Contents

- `settings.json` — model default, hooks (finish/notification sounds), statusline
  wiring, theme, effort level. Uses `$CLAUDE_CONFIG_DIR` (falling back to `~/.claude`)
  for the sound path, so it works regardless of which config directory you use.
- `statusline.sh` — model + effort, project/branch, color-coded context-usage bar,
  and 5h/7d rate-limit usage with local reset times.
- `sounds/` — notification sound used by the Stop/Notification hooks.
- `skills/` — personal skill definitions (`diagnosing-bugs`, `grill-me`, `handoff`,
  `review`, `tdd`).

Not included on purpose: auth tokens/OAuth state, conversation history, session
data, and project memory. Those are machine/account-specific or sensitive and
aren't config — they don't belong in git.

## Setup on a new machine

```sh
./install.sh                    # installs into $CLAUDE_CONFIG_DIR or ~/.claude
./install.sh ~/.claude-personal # or a specific profile directory
```

This copies `statusline.sh`, `sounds/`, and `skills/` into the target directory,
and installs `settings.json` only if one doesn't already exist there (to avoid
clobbering an existing config — merge by hand in that case).

If you use a non-default profile, remember to set `CLAUDE_CONFIG_DIR` in your
shell profile (e.g. `~/.zshrc`) before starting Claude Code:

```sh
export CLAUDE_CONFIG_DIR="$HOME/.claude-personal"
```

Requires `jq`, `git`, and (for the sound hooks) `afplay`/`osascript` — macOS only
as written; adjust the hook commands in `settings.json` for other platforms.
