# Wayland tiling profile (placeholder)

**Status:** not yet implemented. No machine is currently on this profile.

## Intended target

A future laptop running:
- Wayland session (not X11)
- Niri or Sway as the compositor (wlroots, supports `wlr-virtual-pointer-v1`)
- `home-manager` for declarative dotfile + user-environment management on top of NixOS (or Nix on a non-NixOS distro)

## Why this is its own profile

The Ubuntu Dell profile depends on X11 + GNOME assumptions (Mutter, GDM, Dash to Dock, dconf-based shortcut storage, AT-SPI2 with GTK accessibility). Niri/Sway have completely different assumptions:
- No GNOME Shell — top bar comes from `waybar` or similar
- No GDM — `greetd` / `tuigreet` for login
- No Mutter — no Mutter-specific X11 compositor cap on mixed refresh rates
- Shortcut storage is in the compositor's config file, not dconf
- AT-SPI2 still works but window-manager-level keybinds bypass it
- `wlr-virtual-pointer-v1` IS supported → warpd works in its Wayland mode

## Open questions for when this profile is built

- Niri vs Sway — Niri's scrollable tiling vs Sway's i3-style; pick after dogfooding
- home-manager flake structure — separate from this repo, or embedded as a subdir?
- Status bar choice — waybar / hyprland-eq / niri's built-in
- How much of `lks-dev-env`'s current shell/editor config translates 1:1 vs needs forking
- Whether warpd's Wayland mode is mature enough by then or we use something newer

## What lives here today

Just this README. The profile dir is reserved.
