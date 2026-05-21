# Ghostty config — ported from kitty

Ghostty is a GPU-accelerated terminal by Mitchell Hashimoto. This directory is the in-progress port of `lks-dev-env/kitty/kitty.conf` into Ghostty's config syntax. Both can coexist on disk; the active terminal is whichever you launch.

## Why port

- **Sidesteps the nixGL shim entirely**: Ghostty on Ubuntu 24.04 is installed via apt/snap/deb (not nix), so it uses system Mesa directly — no `~/.local/bin/<wrapper>` indirection, no `nixGLIntel`, no PATH-ordering bugs like the one that bit kitty's Ctrl+Alt+T.
- **Active development** with frequent releases and feature parity ramping up.
- **No functional loss for this user**: audit confirmed no kitty exclusives are actively used here — tabs/splits/image-protocol/scrollback all present in Ghostty; kittens / sessions / remote-control unused in current setup; hints-in-terminal handled by tmux-thumbs (terminal-agnostic).

## Install paths (Ubuntu 24.04)

| Method | Command | Notes |
|---|---|---|
| **Snap** | `sudo snap install ghostty --classic` | v1.3.1 by Ken VanDine (Canonical). Auto-updates. |
| **Official deb** | Download from <https://ghostty.org/download>, `sudo dpkg -i ghostty_*.deb` | Mitchell Hashimoto's official build. Manual updates. |
| **Flatpak** | `flatpak install flathub com.mitchellh.ghostty` | Sandboxed — can cause fs/clipboard friction. |

Profile-side wiring (in `profiles/ubuntu-promax14/setup.sh`) is TBD until install method is locked in.

## Notes on the port

### Direct equivalents
| kitty.conf | ghostty config | Notes |
|---|---|---|
| `font_family GeistMono Nerd Font` | `font-family = GeistMono Nerd Font` | |
| `font_size 13.0` | `font-size = 13` | |
| `shell $HOME/.nix-profile/bin/zsh --login` | `command = /home/lukas-shipley/.nix-profile/bin/zsh --login` | |
| `hide_window_decorations yes` | `window-decoration = false` | |
| `window_padding_width 8` | `window-padding-x = 8` + `window-padding-y = 8` | |
| `cursor_shape block` | `cursor-style = block` | |
| `cursor #FD971F` | `cursor-color = #FD971F` | |
| `cursor_blink_interval 0.5` | `cursor-style-blink = true` | Ghostty doesn't expose interval as a number |
| `enable_audio_bell no` | `audible-bell = false` | |
| `scrollback_lines 10000` | `scrollback-limit = 10485760` | Ghostty uses bytes, not lines |
| `background #000000` | `background = #000000` | |
| `foreground #F8F8F2` | `foreground = #F8F8F2` | |
| `color0 #272822` etc. | `palette = 0=#272822` etc. | Same 16-color palette mapping |
| `map alt+left send_text all \x1bb` | `keybind = alt+left=text:\x1bb` | |
| `map ctrl+shift+f5 load_config_file` | `keybind = ctrl+shift+f5=reload_config` | |
| `remember_window_size yes` | `window-save-state = always` | |

### Gaps / things kitty has that ghostty doesn't (yet)
| kitty | ghostty status |
|---|---|
| `cursor_trail 1` | **Not supported** as of v1.3 — track upstream |
| `cursor_shape_unfocused hollow` | Ghostty's `cursor-invert-fg-bg` is a partial equivalent; no exact match |
| `sync_to_monitor` / `repaint_delay` / `input_delay` | Ghostty handles GPU sync internally; no tuning knobs exposed |
| Powerline tab styling | Ghostty's tabs are simpler; no custom powerline rendering |
| Kittens (icat, ssh, hints, etc.) | Not present — but you don't actively use any (audit-confirmed) |
| Remote control via `kitty @` | Limited equivalent via `ghostty +cmd` |

### What carries over unchanged
- **zsh + starship** — shell/prompt, terminal-agnostic. No changes needed.
- **tmux** — multiplexer runs inside any terminal. No changes; tmux-thumbs replaces kitty hints kitten.
- **kitty graphics protocol consumers** (image viewers, markdown previews) — Ghostty supports the protocol natively.

## Coexistence with kitty

Both terminals are configured. Switch your daily driver by:
1. Updating `profiles/ubuntu-promax14/gsettings.sh` to point `Ctrl+Alt+T` at ghostty instead of kitty
2. Updating `~/.local/share/applications/` desktop file defaults
3. Optionally removing the kitty wrapper / uninstalling nix kitty

Until then both run side-by-side and you can A/B them at will.
