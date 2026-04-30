# Usage Guide

Quick reference for the modern unix toolkit and terminal environment.
For the reasoning behind tool choices see [build-notes.md](./build-notes.md).

---

## Shell

**zsh-autosuggestions** — just start typing. A grey ghost shows the most likely completion from
your history. Press `→` or `End` to accept the full suggestion, or keep typing to ignore it.

**zsh-syntax-highlighting** — commands colour green when they resolve to a valid executable, red
when they don't. You know before hitting Enter whether you've mistyped.

**Starship prompt** shows: working dir, git branch + dirty status, active language versions
(Node, Python, Rust, etc.), direnv env name, exit code of the last command if non-zero.
Customize via `~/.config/starship.toml`.

---

## eza — better `ls`

```bash
ls              # icons + colour (aliased from ls)
ll              # long list with git status per file
la              # all files including hidden, with icons
lt              # tree view, 2 levels deep
lt -L 4         # tree, 4 levels deep
eza -la --sort=modified   # sort by modification time
eza -la --sort=size       # sort by size
```

---

## bat — better `cat`

```bash
bat file.py             # syntax highlighted with line numbers
bat --plain file        # colour only, no decorations
bat -A file             # show non-printable characters
bat --diff file         # show only changed lines (requires git)
```

bat is also used automatically by `man` pages and `fzf` previews once configured.

---

## rg — ripgrep (better `grep`)

```bash
rg "TODO"                    # search cwd recursively; respects .gitignore
rg "fn main" --type rust     # only Rust files
rg -l "pattern"              # filenames only, not matches
rg -i "error"                # case-insensitive
rg "pattern" src/            # search a specific directory
rg --hidden "pattern"        # include hidden files/dirs
rg -C 3 "pattern"            # 3 lines of context around each match
```

---

## fd — better `find`

```bash
fd config                    # anything named *config* in cwd
fd -e py                     # all .py files
fd -t f "*.log"              # only regular files matching *.log
fd -t d src                  # directories named *src*
fd --hidden ".env"           # include hidden files
fd -x wc -l                  # run wc -l on each result
```

---

## fzf — fuzzy finder

fzf turns any list into an interactive picker. Key bindings wired in zsh:

```
Ctrl+T    fuzzy-pick a file from cwd — inserts the path at the cursor
Alt+C     fuzzy-cd into a subdirectory
Ctrl+R    handed to atuin (see below) for history search
```

You can pipe anything into fzf:

```bash
ls | fzf                          # pick from ls output
git branch | fzf                  # pick a branch name
cat /etc/hosts | fzf              # search hosts file
kill -9 $(ps aux | fzf | awk '{print $2}')  # fuzzy process kill
```

---

## zoxide — smart `cd`

Builds a frecency database of directories you visit. Gets smarter over time.

```bash
z proj              # jump to the most frecent dir matching "proj"
z mer auto          # multi-token: matches "my-tool-name" etc
zi                  # interactive fuzzy picker of all frecent dirs
z -                 # go back to previous directory (like cd -)
```

The first time you visit a directory with `cd`, zoxide learns it. From then on `z <partial>` gets
you there in a few characters.

---

## atuin — shell history

Replaces the default `Ctrl+R` history search. Stores history in SQLite with metadata (time, host,
working directory, exit code).

```
Ctrl+R              open atuin fuzzy history search
  Tab / Shift+Tab   move through results
  Enter             run the selected command
  Ctrl+D            delete entry from history
  Esc               cancel
```

Filter while searching:

```bash
atuin search "git push"      # non-interactive search
atuin stats                  # most-used commands breakdown
atuin stats --period week    # stats for the past week
```

---

## delta — git diffs

delta is automatically used as the git pager. No extra commands needed — it applies to:

```bash
git diff
git log -p
git show
git stash show -p
```

Useful flags you can pass directly:

```bash
git diff --side-by-side      # delta renders this as two columns
git log --stat               # file-level change summary
```

---

## lazygit — TUI git client

```bash
lazygit        # open TUI in current repo
```

Key bindings inside lazygit:

```
h j k l        navigate panels and items
Space          stage / unstage file or hunk
c              commit (opens commit message editor)
C              commit with conventional commit helper
p              push
P              pull
[  ]           switch between files in diff view
e              open file in $EDITOR
b              branch menu (checkout, new, delete, merge, rebase)
r              rebase menu (interactive rebase onto branch)
s              stash menu
?              context-sensitive help for current panel
q / Ctrl+C     quit
```

Interactive staging (the main reason to use lazygit over the CLI):

1. Select a file in the Files panel
2. Press `e` to view the diff, or use the diff directly in the panel
3. Navigate to a hunk and press `Space` to stage only that hunk
4. `c` to commit — only the staged hunks go in

---

## yazi — TUI file manager

```bash
yazi           # open in current directory
```

Navigation:

```
h / ←          go up to parent directory
l / → / Enter  open file or enter directory
j / k          move down / up
/              search files in current dir
z              jump to frecent dir (zoxide integration)
```

File operations:

```
Space          select file (multi-select)
y              yank (copy) selected
x              cut selected
p              paste
d              move to trash
D              delete permanently
r              rename
a              create new file or directory (end with / for dir)
```

Previews: text files show syntax-highlighted content; images render inline via the Kitty graphics
protocol (requires kitty as the terminal). Press `q` to quit — yazi cds your shell to the last
visited directory.

---

## helix

```bash
hx file.rs        # open file
hx .              # open project (LSP attaches automatically)
hx +42 file.rs    # open at line 42
```

Core model — selection first, then action:

```
w          select next word
e          select to end of word
b          select previous word
x          select current line
%          select entire file
```

Actions on selection:

```
d          delete selection
c          change (delete + enter insert mode)
y          yank (copy)
p          paste after
r          replace selection with typed character
```

Modes:

```
i          insert before selection
a          insert after selection
o          new line below, insert
O          new line above, insert
Esc        return to normal mode
```

Navigation:

```
g g        go to top of file
g e        go to end of file
g d        go to definition (LSP)
g r        go to references (LSP)
Ctrl+O     jump back (after go-to)
space f    fuzzy open file in project
space b    buffer picker
space /    global search (ripgrep)
```

Multiple cursors:

```
C          add cursor on next matching selection
,          collapse to single cursor
```

---

## tmux

Prefix: `Alt+E` (replaces default `Ctrl+B`).

```
Alt+E c        new window
Alt+E n        next window
Alt+E p        previous window
Alt+E "        split pane horizontally
Alt+E %        split pane vertically
Alt+E I        install plugins (first time after editing .tmux.conf)
Alt+E z        zoom / unzoom current pane (fullscreen toggle)
Alt+J          cycle to next pane (no prefix — direct binding)
```

Copy mode (vi):

```
Alt+E [        enter copy mode
v              begin selection
y              yank selection to system clipboard
q              quit copy mode
```

tmux-resurrect:

```
Alt+E Ctrl+S   save session manually
Alt+E Ctrl+R   restore session manually
```

Sessions auto-save every 15 minutes via tmux-continuum and restore automatically on `tmux` start.

---

## Sessionizer

Press `Ctrl+F` from anywhere — inside tmux, outside tmux, in any shell — to open a fuzzy project
picker. Select a directory and you're instantly in a named tmux session rooted there.

```
Ctrl+F    open project picker
Enter     jump to / create that project's session
Esc       cancel
```

**How sessions work:**
- Each project gets a tmux session named after its path relative to `$HOME`:
  `~/dev/my-project` → session `dev_my-project`
- First visit: new session is created, shell starts in that directory
- Return visit: existing session is restored with all panes, scroll history, and running processes
  intact (tmux-continuum saves state every 15 minutes)
- Two projects with the same basename (e.g. `~/dev/config` and `~/work/config`) get distinct
  session names: `dev_config` vs `work_config` — no collision

**Search roots** (edit `~/.local/bin/sessionizer` to add more):
```
~/dev                   main projects
~/nixos-config          nix config
~/plotjuggler_ws/src    ROS workspace packages
~/obs-md                notes
```

**Switching between projects:**
```bash
# From inside tmux: stays in tmux, switches session — no new terminal
Ctrl+F → pick project → instant switch, previous session keeps running in background

# List all live sessions:
tmux ls

# Switch by name without picker:
tmux switch-client -t dev_my-project
```

---

## Status bar

The tmux status bar right side shows live context:

```
⌨ PREFIX    Alt+E has been pressed — tmux is waiting for the next key of a chord.
            Disappears the moment you complete or cancel the binding.
            Useful: stops you wondering why keys are behaving strangely.

🔍 ZOOM     A pane is fullscreened (Alt+E then z to toggle).
            Easy to forget a pane is zoomed and lose track of other panes.

hostname · session   Which machine you're on and which project session is active.
                     The hostname is especially useful when SSH'd into a remote machine
                     — you always know where you are.
```

---

## Secrets

Tokens live in `~/.secrets` (not committed, chmod 600). This file is sourced by `~/.bashrc`,
`~/.zshrc`, and `~/.profile`. To add a new secret:

```bash
echo 'export MY_TOKEN="value"' >> ~/.secrets
```

To verify a secret is set in the current shell:

```bash
echo $MY_TOKEN
```

---

## Kitty

Kitty is configured at `~/.config/kitty/kitty.conf`. To reload config without restarting:

```
Ctrl+Shift+F5    reload kitty.conf
Ctrl+Shift+F2    open kitty.conf in editor
```

Tab management:

```
Ctrl+Shift+T     new tab
Ctrl+Shift+Q     close tab
Ctrl+Shift+→     next tab
Ctrl+Shift+←     previous tab
Ctrl+Shift+Alt+T rename tab
```

Most multiplexing (splits, sessions) is handled by tmux rather than kitty's built-in windows.

**Window title format** (visible in kitty tab bar):
```
bolt · hostname · session · window · pane_title
```
- `bolt` — prepended by kitty's `tab_title_template`
- `hostname` — which machine (critical when SSH'd)
- `session` — active tmux session / project name
- `window` — current window name (usually the running command)
- `pane_title` — set by starship: current directory + active tool versions
