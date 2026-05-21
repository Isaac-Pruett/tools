# ubuntu-promax14

Active profile for **Dell Pro Max 14 MC14250** (Intel Arrow Lake-P, NVIDIA GB203 dGPU) running **Ubuntu with GNOME Shell 46 on X11**.

## Machine state this profile assumes

- Ubuntu 24.x (or later), GNOME Shell 46, X11 session (no Wayland — we do not want Wayland on this machine)
- `apt` is the system package manager; Nix (Determinate Systems installer) is layered on top for user packages
- Dash to Dock extension is enabled by default in Ubuntu's GNOME flavor
- AT-SPI2 daemon (`at-spi-dbus-bus.service`) is running per Ubuntu defaults — verify with `systemctl --user status at-spi-dbus-bus`
- User has dotfile symlinks from the repo's base `install.sh` (zsh, tmux, kitty, starship, etc.)

## What this profile does

In order, `setup.sh` runs each of the following (each step is idempotent and safe to re-run):

1. **apt packages** (`packages.txt`) — bare-minimum system tools this machine wants from apt
2. **GNOME settings** (`gsettings.sh`) — keyboard shortcut swaps + the warpd activation binding
3. **Hint-mode navigation** (`hint-nav/`) — warpd install + config, providing Vimium-style keyboard navigation to anything clickable on the desktop shell

## Hint-mode navigation

See `hint-nav/README.md` for the full design. Short version: press `Super+i` → labeled overlays appear on every clickable UI element on screen → type the label → cursor warps and clicks. Currently scoped to "everything visible" (no Shell-only filter); we'll narrow scope only if the default proves too noisy in practice.

## Why "ubuntu-promax14" not "ubuntu-desktop"

This is a **laptop**, not a desktop. The original directory name was a placeholder. Naming convention: `<distro>-<brand-or-model-shortname>` so machines are individually addressable (`ubuntu-promax14`, future `nixos-thinkpad`, `nixos-laptop2`, etc.).

## Future considerations (not yet implemented)

- CPU governor switch to `performance` or `schedutil` on AC (currently still `powersave`)
- Samsung U32J59x 4K60 enablement (OSD-side toggle, no profile action needed)
- Optional warpd scope filter if the unscoped hints are too noisy
- Track `~/.config/zed/settings.json` and `~/.config/helix/config.toml` into the dotfiles repo if we want them under version control
