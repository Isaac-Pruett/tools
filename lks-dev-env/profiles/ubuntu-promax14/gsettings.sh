#!/usr/bin/env bash
# GNOME settings for ubuntu-promax14.
# Idempotent — every `gsettings set` is harmless to re-run with the same value.
#
# This file IS the documented source of truth for these settings,
# even though the actual values live in dconf, not on the filesystem.
#
# DESIGN: custom keybinding slots are explicitly assigned by purpose below.
# Each `custom<N>` slot has ONE owner; never wholesale-replace the array
# (an earlier version of this script did, and clobbered the user's Ctrl+Alt+T
# binding when it added a warpd entry — that's why this file is now slot-based
# and the array is rebuilt from the union of all owned slots at the end).

set -e

echo "→ gsettings: applying ubuntu-promax14 GNOME tweaks"

# ─── Built-in WM keybindings: Alt+Tab / Alt+Esc swap ──────────────────────────
# Alt+Tab → direct cycle (no popup), Alt+Esc → popup switcher.
# Inverts the GNOME default to match user's muscle memory.
gsettings set org.gnome.desktop.wm.keybindings switch-windows          "['<Alt>Escape']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Escape']"
gsettings set org.gnome.desktop.wm.keybindings cycle-windows           "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings cycle-windows-backward  "['<Shift><Alt>Tab']"

# ─── Custom keybindings — explicit slot model ─────────────────────────────────
KB_BASE='/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings'
SCHEMA='org.gnome.settings-daemon.plugins.media-keys.custom-keybinding'

# custom0 — Ctrl+Alt+T → kitty (via wrapper for nixGLIntel)
# ABSOLUTE PATH is required: gsd-media-keys spawns shortcuts with a PATH that
# puts ~/.nix-profile/bin BEFORE ~/.local/bin. PATH-resolving "kitty" finds
# the bare nix-kitty (no GL libs) → GLX failure → no window. Pointing at the
# wrapper directly sidesteps the PATH ordering.
# Future: swap to ghostty by changing the binary path here.
gsettings set "$SCHEMA:$KB_BASE/custom0/" name    'open terminal (kitty)'
gsettings set "$SCHEMA:$KB_BASE/custom0/" command "$HOME/.local/bin/kitty"
gsettings set "$SCHEMA:$KB_BASE/custom0/" binding '<Control><Alt>t'

# ─── Register all owned slots ─────────────────────────────────────────────────
# Build the array from the explicit list above. ANY future custom binding must
# be added to BOTH a new custom<N>/ block AND this array literal.
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['$KB_BASE/custom0/']"

echo "→ gsettings: done"
