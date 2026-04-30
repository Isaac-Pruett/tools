# Build Notes

Higher-level reasoning behind the tool choices and configuration decisions in this repo.
For usage examples see [usage.md](./usage.md).

---

## Platform strategy

**Current machine: Ubuntu 24.04 + GNOME**
The daily driver right now. Ubuntu is used as-is (no reinstall), with Nix (Determinate Nix) layered on
top for package management. This lets us install the exact same tools that will appear in the NixOS
config without touching apt or snaps for dev tooling. GNOME handles the desktop, display manager,
compositor, and notifications — none of that is configured here.

**Target: NixOS + Wayland + Sway**
The declarative target for new or reimaged machines. The whole desktop stack (compositor, panel,
launcher, notifications, screen lock) is replaced by the Sway ecosystem. Sections marked
`[UBUNTU/GNOME]` or `[NIXOS/WAYLAND]` in the nix files call out where behaviour diverges.

The transition is designed to be low-friction: the shell config, CLI tools, tmux setup, and editor
config are identical on both platforms. Only the desktop layer changes.

---

## Why NixOS

Reproducibility is the core reason. A new machine goes from zero to identical dev environment with
`nixos-rebuild switch`. No drift between machines, no "works on my machine" gaps. Atomic upgrades
mean a bad config change rolls back completely — the bootloader keeps the previous generation.

The tradeoff: Nix has a steep learning curve and the ecosystem quirks (store paths, impure
references) occasionally bite. Worth it for a setup you're going to rebuild across multiple laptops.

---

## Why Wayland + Sway

Wayland is the present, not the future — X11 is in maintenance mode. Sway is a tiling compositor
that is spiritually a Wayland port of i3. The reasons to choose it over GNOME/KDE on NixOS:

- **Tiling by default.** No window dragging; everything has a place. Fast keyboard-driven workflow.
- **Minimal.** Sway + waybar + wofi is ~5 packages. GNOME on NixOS is significantly heavier.
- **Config as code.** `~/.config/sway/config` is a plain text file that goes in dotfiles.
- **First-class Nix support.** The sway module in NixOS is mature and well maintained.

Wayland also closes the class of security issues where any X11 client can read keystrokes from any
other. A relevant concern when running untrusted code or using clipboard managers.

---

## Terminal: Kitty (primary) / Alacritty (NixOS/Wayland alternative)

Both are GPU-accelerated and fast. Kitty was chosen as the current primary because:

- Ships with the **Kitty graphics protocol** — renders images directly in the terminal (used by yazi
  for file previews, and supported by many modern CLI tools).
- Strong configuration story: single `kitty.conf`, hotkey to reload.
- Works identically on X11 (current Ubuntu) and Wayland.

Alacritty is kept commented out in the nix files as the minimal alternative. It is deliberately
featureless (no tabs, no splits, no image protocol) — it delegates everything to tmux. Some people
prefer this strict separation of concerns. It is also slightly faster to start. On Sway/Wayland it
is Wayland-native out of the box.

Kitty uses **AMOLED black + Monokai** (see Colorscheme section). Alacritty would use Catppuccin
Mocha if uncommented — adjust its theme config when switching.

---

## Shell: zsh + starship

**Why zsh over bash:** bash is fine but its autocomplete story requires significant configuration to
approach what zsh gives you with two plugins. zsh is a strict superset of bash — every existing
alias, export, and script works unchanged. The only migration cost is changing three hook lines
(`direnv hook bash` → `direnv hook zsh`, etc.).

**Why zsh over fish:** fish is a different language, not bash-compatible. Existing scripts need
rewriting. The autocomplete fish is famous for is fully replicated in zsh via
`zsh-autosuggestions` + `zsh-syntax-highlighting`. Fish makes sense for a clean-slate setup;
not worth the migration for an existing bash workflow.

**Starship** is the prompt layer. Written in Rust, ~5ms to render. Shows git branch and status,
active language runtime versions, direnv env name, exit code of last command. Config is a single
`~/.config/starship.toml` if you want to customize; defaults are good enough to skip this.

---

## Modern unix toolkit

The standard unix tools (grep, find, cat, ls) were written for a different era. The Rust rewrites
are strictly faster and have better defaults. All are in nixpkgs and are cross-platform.

| Old | New | Why |
|-----|-----|-----|
| `ls` | `eza` | Git status per file, icons, tree view, colour-coded permissions |
| `cat` | `bat` | Syntax highlighting, line numbers, git diff markers in the gutter |
| `grep` | `ripgrep (rg)` | Respects `.gitignore` by default, parallel, 5-10× faster |
| `find` | `fd` | Sane syntax, respects `.gitignore`, colour output |
| Ctrl+R history | `atuin` | SQLite-backed, fuzzy search, filterable by host/dir/exit code |
| `cd` | `zoxide` | Frecency-based jumping: `z proj` goes to the right dir |
| — | `fzf` | Pipes any list into an interactive fuzzy picker; Ctrl+T, Alt+C |
| `git diff` | `delta` | Syntax-highlighted diffs, side-by-side mode, line numbers |
| git CLI | `lazygit` | TUI: stage hunks, rebase interactively, branch management |
| file browser | `yazi` | TUI file manager, image previews via Kitty protocol, zoxide integration |

---

## tmux

tmux is the session layer. It sits between the terminal emulator and the shell, providing:

- **Persistent sessions:** close the terminal, reconnect later, session is still running.
- **Pane splitting:** multiple shells in one terminal window without needing tabs.
- **tmux-resurrect + tmux-continuum:** auto-saves the session layout every 15 minutes and restores
  on `tmux start`. Survives reboots.

The config uses `Alt+E` as the prefix (instead of the default `Ctrl+B`) to avoid conflicts with
editors. Vi copy-mode is enabled; selections pipe to xclip (Ubuntu/X11) or wl-clipboard (Wayland).

**TPM (Tmux Plugin Manager)** manages the plugin installs. After first clone, press `prefix + I`
inside tmux to install the plugins defined in `.tmux.conf`.

**Catppuccin for tmux** provides the status bar theme. The status bar right side shows:
- `⌨ PREFIX` — lights up when the prefix key (Alt+E) is held, waiting for a chord. Prevents
  confusion when keys behave unexpectedly.
- `🔍 ZOOM` — visible when a pane is fullscreened (`Alt+E z`). Easy to forget a pane is zoomed.
- `hostname · session` — which machine and which project. Essential when SSH'd into remote machines.

**Window titles** (`set-titles on`): tmux pushes `hostname · session · window · pane_title` to the
terminal title. Kitty prepends `bolt ·` via `tab_title_template`. The pane title is set by starship
and includes the current directory and active tool versions (Python, Rust, Node, etc.).

---

## Fonts: JetBrainsMono Nerd Font

Nerd Fonts patch a monospace font with thousands of icon glyphs. These are used by:
- starship prompt (git branch icon, language icons)
- eza (file type icons)
- yazi (file icons)
- lazygit (UI elements)
- any prompt / status bar that renders powerline-style segments

JetBrainsMono is the base: excellent readability, clear glyph distinction (`0` vs `O`, `1` vs `l`),
good ligature support. FiraCode is also included as a secondary option — stronger ligatures,
slightly more stylised.

---

## Colorscheme: split — Monokai (kitty) + Catppuccin Mocha (tmux/tools)

**Kitty:** AMOLED pitch black (`#000000`) background with the Monokai palette. True black saves
power on OLED panels and provides maximum contrast. Monokai's accent colours (pink-red, bright
green, purple, cyan, yellow) are high-saturation and easy to distinguish — good for dense terminal
output and syntax highlighting.

**tmux status bar:** Catppuccin Mocha. Its softer pastels work better for persistent UI chrome
(status bar, window tabs) than Monokai's saturated accents, which are better suited to transient
text content. The PREFIX and ZOOM indicators use Monokai red/yellow to stand out against the
Catppuccin background.

**Everything else** (helix, lazygit, bat, starship): Catppuccin Mocha, which has first-class ports
for virtually every tool in the stack. Switching Catppuccin flavour is a find-and-replace across
config files — Latte, Frappé, Macchiato, Mocha are all available.

---

## Secrets management

**Current approach:** `~/.secrets` (chmod 600, not committed) sourced from both `~/.bashrc` and
`~/.zshrc`. Simple, works everywhere, no daemon required.

**Limitation:** GUI apps launched from the desktop (not a terminal) may not inherit the env. For
those cases, `~/.profile` also sources `~/.secrets`, which the login session reads on most display
managers including GDM (Ubuntu/GNOME) and greetd (NixOS).

**Future:** On NixOS, `agenix` or `sops-nix` can manage secrets declaratively, encrypting them in
the repo and decrypting at activation time. Worth adopting when the number of secrets grows or
when multiple machines need the same secrets without manual copying.

---

## Two-track nixpkgs (stable + unstable)

`nixpkgs` is pinned to `nixos-24.11` for stability. A small set of fast-moving packages
(Cursor, Zed) are pulled from `nixpkgs-unstable` because stable lags their release cycles by
months. The unstable channel is passed as `pkgs-unstable` in `specialArgs` so it's only used
explicitly — the rest of the system stays on stable.

Rule of thumb: add to unstable only when the stable version is more than one major release behind
and the gap causes a real problem (missing features, incompatible config format).

---

## Editor: Helix

Helix is a modal editor (like vim/neovim) written in Rust. Chosen over neovim for this setup
because:

- **Zero config to be useful.** Ships with LSP support, tree-sitter syntax highlighting, and
  sensible defaults out of the box. Neovim requires significant plugin configuration to reach
  the same baseline.
- **Rust.** Fast startup, no Lua/VimScript runtime, no plugin manager needed.
- **Selection-first model.** Unlike vim's operator-then-motion model (`dw` = delete word), helix
  uses selection-then-action (`wd` = select word, then delete). More predictable for complex edits.
- **Built-in language server.** `hx .` opens a project and LSP attaches automatically if the
  language server is in PATH.

Helix config lives at `~/.config/helix/config.toml` (optional — defaults are good). The runtime
and grammars are bundled with the nix package; no separate install step needed.

---

## Sessionizer

The sessionizer (`~/.local/bin/sessionizer`) maps projects to named tmux sessions. The workflow:

- Press `Ctrl+F` from anywhere to open an fzf picker of project directories
- Selecting a directory creates or switches to a tmux session named after that path
- Sessions are persistent — tmux-continuum saves state every 15 minutes and restores on reboot
- Session names are derived from the path relative to `$HOME` (`~/dev/my-project` →
  `dev_my-project`) so basename collisions across different parent directories are impossible

This replaces the common pattern of accumulating many unrelated tmux windows in a single session.
Each project has its own session with its own windows, panes, and history. Switching projects is
instant (`switch-client`), not terminal-spawning.

The script's search roots (`~/dev`, `~/nixos-config`, etc.) need to be updated on each new machine
to match the actual project directory layout.

---

## Dotfiles — carrying config to NixOS

These files live in `~` and are independent of the nix config. They need to be symlinked or copied
to any new machine. On NixOS the package list in `configuration.nix` handles installs; these files
handle how those packages are configured and initialized.

**Files to carry over:**

| File | Purpose | NixOS change? |
|------|---------|---------------|
| `~/.config/kitty/kitty.conf` | Terminal theme, font, keybindings | Change `shell` path (see below) |
| `~/.zshrc` | Shell init, PATH, plugins, tool hooks | Remove nix-daemon.sh source (NixOS handles it) |
| `~/.tmux.conf` | tmux prefix, copy mode, TPM plugins | None — copy verbatim |
| `~/.config/starship.toml` | Prompt customization (if added) | None |
| `~/.local/bin/sessionizer` | Project→tmux session picker script | Update search root paths for new machine layout |
| `~/.secrets` | Tokens — recreate manually, never commit | None |

**kitty.conf — shell line on NixOS:**
Currently pinned to the nix-profile path to work around a GNOME session lag (the session's `$SHELL`
env var is set at login and doesn't update when `chsh` is run mid-session, so kitty inherits the
old bash path). On NixOS this isn't an issue — zsh will be the login shell from first boot and
`$SHELL` will be correct. Change the line to:
```
shell zsh --login
```
or remove it entirely (kitty will read `$SHELL` which will be correct on NixOS).

**kitty.conf — keybinding note:**
`map ctrl+shift+f5 load_config_file` is explicit because GNOME intercepts some Ctrl+Shift
combinations before they reach applications. On Sway this interception doesn't happen — the line
can stay or be removed; kitty's built-in default already maps this key.

**~/.zshrc — what changes on NixOS:**
Remove or guard the nix-daemon.sh source line — on NixOS the nix environment is set up by the
system before your shell starts, sourcing it again is a no-op at best:
```zsh
# Remove this on NixOS:
[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```
Everything else in `.zshrc` (plugins, tool hooks, aliases, PATH additions) carries over verbatim.

**Shell init order — matters for correctness:**
Tools must be initialized in this order in `.zshrc`:
1. nix-daemon (PATH for all nix tools — omit on NixOS)
2. secrets
3. PATH overrides (`~/.local/bin` first, so wrappers shadow nix binaries if needed)
4. zsh-autosuggestions
5. fzf completion + key-bindings
6. zoxide (`eval "$(zoxide init zsh)"`)
7. atuin (`eval "$(atuin init zsh)"`) — overwrites fzf's Ctrl+R with better history search
8. direnv
9. starship — must be last (sets PS1; anything after it that also sets PS1 wins)
10. zsh-syntax-highlighting — must be sourced after everything else or it misses dynamic completions

**tmux default-shell:** `.tmux.conf` pins `default-shell` explicitly to the nix zsh path. This is
necessary because tmux reads `$SHELL` once when the server starts — if the server started before a
`chsh` took effect (or before a login/logout cycle), every new window gets the old shell. On NixOS
the shell path will be `/run/current-system/sw/bin/zsh` or wherever NixOS places it; update the
`default-shell` line accordingly.

**tmux — first boot on a new machine:**
1. Clone TPM: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
2. Start tmux, then press `prefix + I` (Alt+E then I) to install plugins
3. tmux-continuum auto-restore kicks in on subsequent starts once a session has been saved

---

## Version control tooling

**delta** replaces the default git diff output. It adds syntax highlighting, line numbers, and
cleaner hunk headers. Configured as the core pager so it applies to `git diff`, `git log -p`,
`git show`, and `git stash show` automatically.

**lazygit** is a full TUI for git. The primary use case is interactive staging (stage individual
hunks, not whole files) and interactive rebase without memorising git flags. It also makes branch
management and stash operations fast.

**glab** is the GitLab CLI. It handles MR creation, pipeline inspection, issue management, and
CI/CD triggering from the terminal. Requires `GITLAB_TOKEN` in the environment (sourced from
`~/.secrets`).
