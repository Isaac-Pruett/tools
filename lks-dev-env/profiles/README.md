# Profiles

Per-machine setup layer on top of the dotfiles in this repo. The base `install.sh` at the repo root handles dotfile **symlinks** that every machine wants (zsh, tmux, kitty, etc.). Profiles handle the machine-specific layer on top of that: which packages to install, which OS settings to set, which custom tooling to wire up.

## How dispatch works

A symlink at `profiles/.active-profile` points to the profile directory this machine wants:

```
profiles/.active-profile → ubuntu-promax14
```

The repo-root `install.sh` checks for that symlink at the end. If present, it sources the target's `setup.sh`. If absent, `install.sh` just does the common dotfile linking and exits.

To switch a machine to a profile, set the symlink manually:

```
ln -sfn ubuntu-promax14 ~/tools/lks-dev-env/profiles/.active-profile
```

Then re-run `install.sh`. Idempotent — safe to re-run any time.

## Current profiles

| Profile | Status | For |
|---|---|---|
| `ubuntu-promax14/` | Active on Dell Pro Max 14 MC14250 (this machine — Intel Arrow Lake-P) | Ubuntu GNOME on X11, with desktop hint-mode navigation via warpd |
| `wayland-tiling/` | Placeholder | Future Wayland laptop running Niri or Sway with home-manager |
| `nixos/` | Placeholder | Future NixOS workstation (declarative, declarative) |

Each profile owns its own:
- `README.md` — describes the machine state this profile assumes, and what it does
- `setup.sh` — idempotent installer; safe to re-run
- Subdirs / config files — anything specific to that machine's tooling

## Design notes (for future-me)

- **No abstraction layer.** Each profile is a shell script + supporting files. When a real second active profile lands, evaluate whether to factor out a `common/` directory. Don't prematurely.
- **Idempotent steps only.** Every check should be `if not installed → install`, every `gsettings set` is harmless on re-run, every symlink uses `ln -sfn`.
- **gsettings as source of truth.** GNOME custom shortcuts and tweaks live in dconf, not files. The profile's `gsettings.sh` is what writes them — so the script IS the documented config, even though the actual setting is in the OS database.
- **Don't track secrets here.** Anything sensitive lives in `~/.secrets` and gets sourced separately.
