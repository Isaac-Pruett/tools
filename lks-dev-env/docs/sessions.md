# Sessions — project-aware tmux launching

Project-aware tmux session picker. Replaces the old "always-`main`-or-pronounceable" auto-tmux logic. Sessions are named for projects (not random), branches get dedicated worktrees, and `cockpit` rebuilds the daily multi-monitor layout from the same index.

## Components

| Component | Path | Role |
|---|---|---|
| Index | `~/.config/sessions.toml` | Source of truth for projects, branches, utilities, cockpit layout |
| Picker | `~/tools/lks-dev-env/scripts/session-picker` | Python script — reads toml + live tmux state, fzf, attach/create |
| Template | `~/tools/lks-dev-env/scripts/sessions.toml.example` | Sanitized starter copy (no work content) |
| Auto-launch | `~/tools/lks-dev-env/zsh/zshrc` | Replaces the old auto-tmux block — `exec session-picker --auto` |
| Direct alias | `tx <name>` in zshrc | Direct attach/create by name; no arg → fires picker |
| Cockpit | `~/tools/lks-dev-env/profiles/ubuntu-promax14/scripts/cockpit` | Daily layout — reads `[cockpit]` block + MRU |
| MRU | `~/.cache/sessions-mru` | Written by picker on each non-utility selection; read by cockpit |

## Naming convention

| Type | Session name | Example |
|---|---|---|
| Tool / personal repo on default branch | `<name>` | `lks-dev-env` |
| Standalone project repo on default branch | `<name>` | `agent-flow` |
| Declared branch subproject | `<branch-slug>` | `feature-x` |
| Repo on an undeclared off-default branch | `<repo>@<branch>` | `myrepo@hotfix-x` (auto-suffix shown only on deviation) |
| Utility | `<name>` | `btop` |
| Ad-hoc | pronounceable (`qovu`, `hexel`, …) | for spontaneous test/teardown |

Session names are unique slugs — flat namespace, no parent encoding. The toml entry's `name` field becomes the session name verbatim.

## Picker flow

`session-picker` (no args or `--auto`):

1. Reads `~/.config/sessions.toml` + `tmux list-sessions`.
2. Builds entries:
   - **Detached / attached** existing sessions first (top of list = most recently active).
   - Then **tool / project / branch / bare / utility** entries from the toml (any name already covered by a live session is shadowed and not duplicated).
   - **`[ad-hoc]`** for a pronounceable spontaneous session.
   - **`[skip]`** for "bare shell, no tmux".
3. Pipes to `fzf` (column 1 is hidden key, column 2 is the display label).
4. Selection dispatches:
   - **Detached/attached** → `tmux attach-session -t =NAME` (or `switch-client` if already inside tmux).
   - **Tool / Project / Bare** → `cd` to `path`, create session, attach.
   - **Branch** → `cd` to `worktree`, create session, attach. **If the worktree directory doesn't exist, picker prints the exact `git worktree add` command and exits non-zero.** No magic creation — predictable, educational.
   - **Utility** → create session with `command` as the first window's process.
   - **Ad-hoc** → generate a unique pronounceable name, create + attach.
   - **Skip** → exit 0 (zshrc continues with a bare shell).
5. On `ESC`: defaults to ad-hoc (matches the "I just want a quick scratch shell" intent).

`session-picker --ensure NAME`: create the named session detached and return — used by `cockpit` to materialize sessions before opening ghostty clients to them.

`session-picker --query Q`: prefill fzf with `Q` (used by `tx` when the name doesn't match an existing session).

`session-picker NAME` (no `--ensure`): direct attach/create by name; bypasses fzf.

## `tx` shortcut

```zsh
tx                 # no arg = open picker
tx myrepo          # exact name = direct attach/create
tx my              # partial name = picker prefilled with "my"
```

The name `tx` is just a chosen alias — `t` for tmux, `x` for execute/switch. Rename if you want; only invoked from your interactive shell.

## Cockpit

`cockpit` (no args) restores the daily 3-monitor layout:

| Monitor | Slot | Source |
|---|---|---|
| 1 — side (vertical) | Pinned | `[cockpit].monitor_1` in toml |
| 2 — main | **MRU project** | First non-pinned project in `~/.cache/sessions-mru`. Falls back to `[cockpit].monitor_2_default` when MRU is empty. |
| 3 — built-in (laptop screen) | Pinned | `[cockpit].monitor_3` in toml |

`cockpit a b c`: explicit per-monitor override (any of the three can be `""` to skip a monitor).

Cockpit uses `session-picker --ensure NAME` to materialize sessions, so the cwd / branch / command for each is whatever the toml dictates. Same naming and behavior as picking interactively.

## Worktrees for branch subprojects

The `[[branch]]` table lets you treat individual git branches as standalone sessions, each in its own worktree:

```toml
[[branch]]
name = "feature-x"
worktree = "~/code/myrepo-worktrees/feature-x"
branch = "feature/x"
parent = "myrepo"
```

If `worktree` doesn't exist when you pick this session, the picker prints the create command derived from the parent project's path (so it works regardless of whether you're using a bare repo + worktrees or a standard checkout):

```
worktree not found: ~/code/myrepo-worktrees/feature-x
create with:
  git -C ~/code/myrepo worktree add ~/code/myrepo-worktrees/feature-x feature/x
```

After creating it once, the session attaches normally on every subsequent pick. Removing a worktree (`git worktree remove`) doesn't break the toml entry — picker just prompts for re-creation on next attempt.

## Escape hatches

- `NO_TMUX_AUTO=1 ghostty` — open ghostty, skip the picker entirely
- `[skip]` entry in the picker — same effect, picked interactively
- `ESC` in fzf — falls through to ad-hoc pronounceable session (good for "just give me a scratch shell")

## Editing the index

`~/.config/sessions.toml` is read on every picker run, so changes take effect immediately. Schema in `scripts/sessions.toml.example`. Six table types: `tool`, `project`, `branch`, `bare`, `utility`, `cockpit` (single-instance).

A `~/.config/sessions.toml` is auto-created from the template on a fresh machine by `install.sh`. The template has no work content — edit to add your own projects.
