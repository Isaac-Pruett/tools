# Terminal startup model

How a new terminal becomes a productive workspace in this dev-env, end to
end. This doc supersedes the old "every Ctrl+Alt+T auto-attaches a tmux
session" behavior — the current default is **plain zsh on launch, explicit
`tx <name>` to enter a session**.

See also: [`docs/sessions.md`](sessions.md) for the session schema +
sessions.toml layout, [`tmux/keybinds.md`](../tmux/keybinds.md) for tmux
keybinds.

## Default flow

```
Ctrl+Alt+T  → ghostty → zsh                       # plain shell, in $HOME
   ↓
   tx myproject                                     # attach project session
   tx <new-thing> -g study                        # create new study session
   tx                                             # ad-hoc pronounceable session
   sp                                             # fzf picker over all sessions
```

No tmux runs at terminal startup by default. The terminal stays
lightweight; tmux only enters when you ask for it.

## Why this changed

Earlier behavior auto-attached every fresh terminal to a generated
pronounceable session (`gaba`, `xeto`, etc.). It accumulated dozens of
small ad-hoc sessions over the day, the cwd was always `$HOME` rather
than a project root, and `tmux-continuum`'s background save churned
through them all. The session inventory was full of one-shot scratch.

Now the model matches the actual workflow:

- **Project sessions** (named, defined in `~/.config/sessions/*.toml`)
  are entered explicitly with `tx <name>`. Cwd lands at the project's
  worktree path automatically.
- **Study / scratch** are created with `tx <name> -g study` (or any
  other group) — same `tx` surface, optional flag.
- **One-shot ad-hoc** lands you in a pronounceable name via `tx` (no
  args). Use these freely; they don't pollute the canon.

## The tools

| Cmd | Action |
|---|---|
| `tx` | Open the fzf session picker |
| `tx <name>` | Attach if it exists, else picker pre-queried with `<name>` |
| `tx <name> -g <group>` | Create a new entry (group: study/tool/project/branch/bare/utility) + mkdir its ctx dir + attach |
| `sp` | Alias for `session-picker` — same as `tx` with no args |
| `ctx` | Open current session's ctx.md in `$EDITOR` |
| `ctx <name>` | Open named session's ctx.md |
| `ctx -` | Append from stdin with timestamp header |
| `ctx --tail [-n N]` | Last N lines of current session's ctx.md |
| `ctx --list` | Every session's ctx with file sizes |

Inside tmux, `prefix G/H/J` opens new local windows that SSH to remote
hosts defined in `~/.tmux.conf.local` (private file, not in the repo).

## Continuum / Resurrect

Auto-save and auto-restore are **disabled**. The resurrect plugin is
still loaded for manual use:

| Keybind | Action |
|---|---|
| `prefix Ctrl-s` | Save current tmux server state to `~/.tmux/resurrect/last` |
| `prefix Ctrl-r` | Restore from the last save (recreates sessions, windows, panes, cwd) |

Reason: continuum's `@continuum-restore 'on'` printed "couldn't find
resurrect file" errors on fresh boots when no save existed, and the
15-minute auto-save churned through ad-hoc/pronounceable sessions we
didn't care to restore. With explicit save:

- Hit `prefix Ctrl-s` after settling into a session arrangement you
  want to survive a reboot (project sessions with specific layouts,
  long-running debug sessions, etc.).
- After reboot, hit `prefix Ctrl-r` to bring them back.
- Ad-hoc sessions you didn't bother to save → start clean next boot.

Project sessions defined in `sessions.toml` don't need this most of the
time: `tx myproject` post-reboot recreates the session with the right
cwd, ctx dir, and worktree pointer. Resurrect only matters when you
care about preserving the window/pane layout or scrollback.

## Opting back into auto-attach

If you want every Ctrl+Alt+T to land in a pronounceable session again
(the old behavior), export `LKS_TMUX_AUTO=1` in `~/.zshrc.local`:

```sh
# ~/.zshrc.local
export LKS_TMUX_AUTO=1
```

`~/.zshrc.local` is sourced at the end of the tracked `~/.zshrc` and
isn't pushed to the public repo.

## Startup cost budget

Approximate steady-state cost of a Ctrl+Alt+T launch under the new model:

| Stage | Time |
|---|---|
| Ghostty process spawn | ~50–200 ms |
| zsh init (zshrc + plugins) | ~80 ms |
| Starship prompt first render | ~5 ms |
| Total to interactive prompt | **< 300 ms** |

Compare to the old auto-tmux model (~600 ms+ because of the Python
pronounceable-name gen + tmux server attach + first prompt inside
tmux). Saving roughly half a second per launch.

If you then `tx myproject`, that's an additional ~50 ms for the picker
direct-attach. Still under a second total.

## Mental model

> **Terminals are cheap. Sessions are deliberate.**

A Ctrl+Alt+T window is a disposable scratch shell. If you want to do
project work, name the session (`tx myproject`) so it shows up in your
session inventory, attaches the right cwd, and gives you a ctx.md to
write notes against.

The fewer ad-hoc sessions you accumulate, the more meaningful your
session list — and the easier it is to identify what was worth
resurrecting after a reboot.
