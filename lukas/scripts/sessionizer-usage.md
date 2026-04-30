# Sessionizer

A fuzzy project-directory picker that creates or reattaches to a named tmux session for each directory. Press one key from anywhere and land in the right session.

---

## Why

tmux sessions are long-lived workspaces, but switching between them by name requires knowing the name. The sessionizer replaces that with a visual fuzzy picker: you see your directories, not session IDs. Each directory gets exactly one session — selecting it a second time reattaches to the running session rather than creating a duplicate.

---

## Dependencies

| Tool | Required | Purpose |
|------|----------|---------|
| tmux | yes | session management |
| fzf  | yes | fuzzy picker UI |
| fd   | no  | faster directory search (falls back to `find`) |
| eza  | no  | richer preview (falls back to `ls`) |

---

## Installation

```bash
cp scripts/sessionizer ~/.local/bin/sessionizer
chmod +x ~/.local/bin/sessionizer
```

Wire it to a key in your shell (outside tmux):

```bash
# ~/.zshrc or ~/.bashrc
bindkey -s '^f' 'sessionizer\n'   # zsh
bind -x '"\C-f": sessionizer'     # bash
```

And in tmux (opens a floating popup — preferred, stays inside tmux):

```
# ~/.tmux.conf
bind -n C-f display-popup -E -w 60% -h 50% "sessionizer"
```

The tmux binding takes priority over the shell binding when inside a tmux pane, so you only need both if you also use the shell outside tmux.

---

## Usage

```
Ctrl+F          open the directory picker
↑ / ↓           navigate
type            filter by name
Enter           jump to / create session for selected directory
Esc             cancel
```

From **inside tmux**: switches the current client to the target session — no new window, current session keeps running in the background.

From **outside tmux**: attaches your terminal to the target session, starting the tmux server if needed.

---

## Session naming

Session names are derived from the directory path relative to `$HOME`:

| Directory | Session name |
|-----------|-------------|
| `~/dev/my-project` | `dev_my-project` |
| `~/work/config` | `work_config` |
| `~/dev/config` | `dev_config` |
| `~` (home itself) | `home` |
| `/tmp/scratch` | `_tmp_scratch` |

Two projects with the same basename in different roots get distinct names — no collision.

Characters `/`, `.`, `:`, and space are all converted to `_`.

---

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SESSIONIZER_ROOTS` | `$HOME` | Colon-separated list of root directories to search |
| `SESSIONIZER_DEPTH` | `1` | How many levels deep to search within each root |

```bash
# Search direct subdirs of ~/dev and ~/work only
export SESSIONIZER_ROOTS="$HOME/dev:$HOME/work"

# Also search one level inside those subdirs
export SESSIONIZER_DEPTH=2
```

---

## How session lookup works

1. **Exact name match** — looks for a live tmux session whose name matches the derived name. If found, switches immediately.
2. **Path match fallback** — if no exact match, scans all live sessions for one whose working directory matches the selected path. Handles sessions that exist under a different name (e.g. manually created, or renamed).
3. **Create** — if neither match, creates a new detached session rooted at the selected directory and prints `no save found for 'name', starting fresh`.

Session state (panes, scroll history, running processes) persists across detach/reattach for as long as the tmux server is running. After a reboot, pair with **tmux-resurrect** + **tmux-continuum** for automatic restore.

---

## Integration with tmux-resurrect / tmux-continuum

With continuum configured to auto-restore (`@continuum-restore 'on'`), all sessions are rebuilt on tmux start after a reboot. The sessionizer's path-match fallback (step 2 above) means it will find resurrect-restored sessions correctly even if the session name or path has minor differences (e.g. a trailing slash that tmux adds to `session_path`).

---

## Bugs fixed in this version

- **Prefix-match false positive**: plain `tmux has-session -t name` does prefix matching — `foo` would match `foobar`, preventing `foobar` from ever getting its own session. Fixed by using the `=name` exact-match syntax (requires tmux 3.1+).
- **Trailing slash mismatch**: `fd` appends trailing slashes to directory paths; tmux's `session_path` also includes them for some sessions. Both are stripped before any comparison.
- **Colon separator in path fallback**: the original fallback used `:` to join session name and path, which `awk -F:` would split incorrectly for paths containing colons. Fixed by using a tab separator.
