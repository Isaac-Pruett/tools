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

# ─── Power: NEVER auto-suspend ────────────────────────────────────────────────
# User wants suspend triggered ONLY by them — closing the lid or stepping away
# should leave processes running. Lock the screen manually with Super+L (or F12).
# Suspend manually with Super+Shift+L. Screen still blanks + locks after 5min
# idle (unchanged) for security, but blanking is purely visual and does NOT
# pause processes.
gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action      'nothing'
gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type      'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

# Lock screen: Super+L (default) + F12 (second binding for one-hand convenience).
# Suspend: Super+Shift+L — manual-only, paired with Super+L by mnemonic.
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>l', 'F12']"
gsettings set org.gnome.settings-daemon.plugins.media-keys suspend     "['<Super><Shift>l']"

# ─── Custom keybindings — explicit slot model ─────────────────────────────────
KB_BASE='/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings'
SCHEMA='org.gnome.settings-daemon.plugins.media-keys.custom-keybinding'

# custom0 — Ctrl+Alt+T → ghostty
# ghostty is apt-installed via the mkasberg PPA → /usr/bin/ghostty, uses system
# Mesa directly (no nixGL wrapper needed). Switched from kitty 2026-05-21.
# Kitty wrapper at ~/.local/bin/kitty still exists as fallback — launch via app
# menu or `kitty &` if needed.
gsettings set "$SCHEMA:$KB_BASE/custom0/" name    'open terminal (ghostty)'
gsettings set "$SCHEMA:$KB_BASE/custom0/" command '/usr/bin/ghostty'
gsettings set "$SCHEMA:$KB_BASE/custom0/" binding '<Control><Alt>t'

# custom1 — Shift+Alt+S → Frog OCR (text extraction from screen)
gsettings set "$SCHEMA:$KB_BASE/custom1/" name    'Frog OCR'
gsettings set "$SCHEMA:$KB_BASE/custom1/" command 'flatpak run com.github.tenderowl.frog'
gsettings set "$SCHEMA:$KB_BASE/custom1/" binding '<Shift><Alt>s'

# custom2 — Shift+Ctrl+Esc → GNOME System Monitor (Task-Manager-equivalent)
gsettings set "$SCHEMA:$KB_BASE/custom2/" name    'System Monitor'
gsettings set "$SCHEMA:$KB_BASE/custom2/" command 'gnome-system-monitor'
gsettings set "$SCHEMA:$KB_BASE/custom2/" binding '<Shift><Control>Escape'

# cockpit (named slot) — Super+Shift+Return → cockpit 3-monitor launcher
# Uses a string slot name instead of customN — GNOME accepts arbitrary slot
# names in the array; named is clearer than re-using a numeric.
gsettings set "$SCHEMA:$KB_BASE/cockpit/" name    'Cockpit launcher (3-monitor multi-window)'
gsettings set "$SCHEMA:$KB_BASE/cockpit/" command "$HOME/.local/bin/cockpit"
gsettings set "$SCHEMA:$KB_BASE/cockpit/" binding '<Super><Shift>Return'

# custom5/6/7 — Super+Alt+1/2/3 → move focused window to monitor 1/2/3
# Was Alt+1/2/3 originally — moved to Super+Alt because plain Alt+N collides
# with app shortcuts (terminal tab switch, browser tab switch, Slack sidebar).
# move-to-monitor script lives in profile scripts/ — symlinked into PATH.
gsettings set "$SCHEMA:$KB_BASE/custom5/" name    'Move window to monitor 1'
gsettings set "$SCHEMA:$KB_BASE/custom5/" command "$HOME/.local/bin/move-to-monitor 1"
gsettings set "$SCHEMA:$KB_BASE/custom5/" binding '<Super><Alt>1'
gsettings set "$SCHEMA:$KB_BASE/custom6/" name    'Move window to monitor 2'
gsettings set "$SCHEMA:$KB_BASE/custom6/" command "$HOME/.local/bin/move-to-monitor 2"
gsettings set "$SCHEMA:$KB_BASE/custom6/" binding '<Super><Alt>2'
gsettings set "$SCHEMA:$KB_BASE/custom7/" name    'Move window to monitor 3'
gsettings set "$SCHEMA:$KB_BASE/custom7/" command "$HOME/.local/bin/move-to-monitor 3"
gsettings set "$SCHEMA:$KB_BASE/custom7/" binding '<Super><Alt>3'

# focus-zen / focus-obsidian / focus-slack — Super+Z / Super+O / Super+S
# Each runs focus-app, which calls `wmctrl -xa <class>` to raise the existing
# window; if no window exists, it launches the app fresh.
#
# Super+O and Super+S collide with GNOME built-ins (rotate-video-lock-static
# and toggle-quick-settings) which win over custom bindings. We clear them
# below so the custom bindings fire. Super+Z is free.
gsettings set org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static "['XF86RotationLockToggle']"
gsettings set org.gnome.shell.keybindings toggle-quick-settings "[]"

gsettings set "$SCHEMA:$KB_BASE/focus-zen/" name    'Focus Zen browser'
gsettings set "$SCHEMA:$KB_BASE/focus-zen/" command "$HOME/.local/bin/focus-app zen"
gsettings set "$SCHEMA:$KB_BASE/focus-zen/" binding '<Super>z'
gsettings set "$SCHEMA:$KB_BASE/focus-obsidian/" name    'Focus Obsidian'
gsettings set "$SCHEMA:$KB_BASE/focus-obsidian/" command "$HOME/.local/bin/focus-app obsidian"
gsettings set "$SCHEMA:$KB_BASE/focus-obsidian/" binding '<Super>o'
gsettings set "$SCHEMA:$KB_BASE/focus-slack/" name    'Focus Slack'
gsettings set "$SCHEMA:$KB_BASE/focus-slack/" command "$HOME/.local/bin/focus-app slack"
gsettings set "$SCHEMA:$KB_BASE/focus-slack/" binding '<Super>s'

# ─── Clean up stale orphan slots ──────────────────────────────────────────────
# custom4 used to hold the kitty Ctrl+Alt+T binding before we moved to ghostty
# at custom0. It's dormant but lingering in dconf — remove so future audits
# don't get confused.
dconf reset -f "$KB_BASE/custom4/" 2>/dev/null || true

# ─── Register all owned slots ─────────────────────────────────────────────────
# Build the array from the explicit list above. ANY future custom binding must
# be added to BOTH a new slot block AND this array literal.
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['$KB_BASE/custom0/', '$KB_BASE/custom1/', '$KB_BASE/custom2/', '$KB_BASE/cockpit/', '$KB_BASE/custom5/', '$KB_BASE/custom6/', '$KB_BASE/custom7/', '$KB_BASE/focus-zen/', '$KB_BASE/focus-obsidian/', '$KB_BASE/focus-slack/']"

echo "→ gsettings: done"
