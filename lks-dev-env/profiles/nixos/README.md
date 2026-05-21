# NixOS profile (placeholder)

**Status:** not yet implemented. No machine is currently on this profile.

## Intended target

A NixOS-managed workstation. Likely candidates:
- A successor to the current Ubuntu Dell that's been migrated to NixOS
- A new desktop / server box where declarative config is preferred from day one
- The declarative work machines, which already run NixOS (see `~/dev/my-project/nixos/` for prior art)

## Why this is its own profile

On NixOS, almost nothing in the ubuntu-desktop profile applies directly:
- No `apt` — packages declared in `configuration.nix` or a flake
- No need for `~/.npm-global` workaround (npm packages can go through nixpkgs)
- No need for `services.gnome.at-spi2-core.enable` as a profile step (it's a NixOS option that lives in the system flake)
- `home-manager` may or may not be in use — TBD
- system-update, the workstation stack, and friends are all consumable as Nix packages via the my-project flake

## What this profile would manage

Even on NixOS, this profile would still handle the **user-environment** layer that the system config doesn't:
- The dotfile symlinks (zsh, tmux, kitty, helix, lazyvim) — same as the base `install.sh`
- Any user-level config NixOS won't touch (e.g. `~/.config/zed/`)
- Wiring up custom keybinds via `gsettings` (if NixOS + GNOME) or compositor config (if NixOS + tiling)
- The hint-nav setup, if applicable

The actual nixpkgs go in the system flake, not here.

## What lives here today

Just this README.
