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
gsettings set "$SCHEMA:$KB_BASE/cockpit/" binding '<Super><Alt>Return'

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

# Clear dash-to-dock's app-shift-hotkey-{1,2,3} (default: <Shift><Super>{1,2,3}).
# Those would shadow our focus-monitor bindings below. They're a niche
# "launch new instance of dock-pinned app N" feature — not worth keeping.
gsettings set org.gnome.shell.extensions.dash-to-dock app-shift-hotkey-1 "[]" 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock app-shift-hotkey-2 "[]" 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock app-shift-hotkey-3 "[]" 2>/dev/null || true

# Mnemonic 1:1 aliases for the same monitor-move action.
# L=LG (1), S=Samsung (2), D=Dell built-in (3). Same commands as custom5/6/7.
gsettings set "$SCHEMA:$KB_BASE/mon-l/" name    'Move window to LG (monitor 1)'
gsettings set "$SCHEMA:$KB_BASE/mon-l/" command "$HOME/.local/bin/move-to-monitor 1"
gsettings set "$SCHEMA:$KB_BASE/mon-l/" binding '<Super><Alt>l'
# Super+Alt+A — left-hand-friendly alias of Super+Alt+L (both → monitor 1)
gsettings set "$SCHEMA:$KB_BASE/mon-a/" name    'Move window to LG (monitor 1, alt key)'
gsettings set "$SCHEMA:$KB_BASE/mon-a/" command "$HOME/.local/bin/move-to-monitor 1"
gsettings set "$SCHEMA:$KB_BASE/mon-a/" binding '<Super><Alt>a'
gsettings set "$SCHEMA:$KB_BASE/mon-s/" name    'Move window to Samsung (monitor 2)'
gsettings set "$SCHEMA:$KB_BASE/mon-s/" command "$HOME/.local/bin/move-to-monitor 2"
gsettings set "$SCHEMA:$KB_BASE/mon-s/" binding '<Super><Alt>s'
gsettings set "$SCHEMA:$KB_BASE/mon-d/" name    'Move window to Dell built-in (monitor 3)'
gsettings set "$SCHEMA:$KB_BASE/mon-d/" command "$HOME/.local/bin/move-to-monitor 3"
gsettings set "$SCHEMA:$KB_BASE/mon-d/" binding '<Super><Alt>d'

# Super+Shift+<letter|num> → FOCUS the MRU window on the matching monitor.
# Parallel set to mon-l/s/d above (which MOVE the current window). Walks
# _NET_CLIENT_LIST_STACKING top→bottom and activates the first window whose
# center sits in the target monitor's bbox.
gsettings set "$SCHEMA:$KB_BASE/focus-mon-a/" name    'Focus MRU window on LG (monitor 1)'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-a/" command "$HOME/.local/bin/focus-monitor a"
gsettings set "$SCHEMA:$KB_BASE/focus-mon-a/" binding '<Super><Shift>a'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-s/" name    'Focus MRU window on Samsung (monitor 2)'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-s/" command "$HOME/.local/bin/focus-monitor s"
gsettings set "$SCHEMA:$KB_BASE/focus-mon-s/" binding '<Super><Shift>s'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-d/" name    'Focus MRU window on Dell built-in (monitor 3)'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-d/" command "$HOME/.local/bin/focus-monitor d"
gsettings set "$SCHEMA:$KB_BASE/focus-mon-d/" binding '<Super><Shift>d'
# Numeric aliases for the same actions (1/2/3 = L/S/D respectively).
gsettings set "$SCHEMA:$KB_BASE/focus-mon-1/" name    'Focus MRU window on LG (numeric)'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-1/" command "$HOME/.local/bin/focus-monitor 1"
gsettings set "$SCHEMA:$KB_BASE/focus-mon-1/" binding '<Super><Shift>1'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-2/" name    'Focus MRU window on Samsung (numeric)'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-2/" command "$HOME/.local/bin/focus-monitor 2"
gsettings set "$SCHEMA:$KB_BASE/focus-mon-2/" binding '<Super><Shift>2'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-3/" name    'Focus MRU window on Dell built-in (numeric)'
gsettings set "$SCHEMA:$KB_BASE/focus-mon-3/" command "$HOME/.local/bin/focus-monitor 3"
gsettings set "$SCHEMA:$KB_BASE/focus-mon-3/" binding '<Super><Shift>3'

# focus-zen / focus-obsidian / focus-slack — Super+Z / Super+O / Super+S
# Each runs focus-app, which calls `wmctrl -xa <class>` to raise the existing
# window; if no window exists, it launches the app fresh.
#
# Super+O and Super+S collide with GNOME built-ins (rotate-video-lock-static
# and toggle-quick-settings) which win over custom bindings. We clear them
# below so the custom bindings fire. Super+Z is free.
gsettings set org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static "['XF86RotationLockToggle']"
gsettings set org.gnome.shell.keybindings toggle-quick-settings "[]"

# Super+Alt+s defaults to GNOME a11y screen-reader toggle (Orca). It eats the
# keypress before mon-s (Super+Alt+s → move to Samsung) can fire. Clear it.
# Orca can still be toggled via Settings → Accessibility if needed.
gsettings set org.gnome.settings-daemon.plugins.media-keys screenreader "[]"

gsettings set "$SCHEMA:$KB_BASE/focus-zen/" name    'Focus Zen browser'
gsettings set "$SCHEMA:$KB_BASE/focus-zen/" command "$HOME/.local/bin/focus-app zen"
gsettings set "$SCHEMA:$KB_BASE/focus-zen/" binding '<Super>z'
# Super+B — left-hand-friendly alias for Super+Z (both focus Zen).
gsettings set "$SCHEMA:$KB_BASE/focus-zen-b/" name    'Focus Zen browser (Super+B alias)'
gsettings set "$SCHEMA:$KB_BASE/focus-zen-b/" command "$HOME/.local/bin/focus-app zen"
gsettings set "$SCHEMA:$KB_BASE/focus-zen-b/" binding '<Super>b'
gsettings set "$SCHEMA:$KB_BASE/focus-obsidian/" name    'Focus Obsidian'
gsettings set "$SCHEMA:$KB_BASE/focus-obsidian/" command "$HOME/.local/bin/focus-app obsidian"
gsettings set "$SCHEMA:$KB_BASE/focus-obsidian/" binding '<Super>o'
gsettings set "$SCHEMA:$KB_BASE/focus-slack/" name    'Focus Slack'
gsettings set "$SCHEMA:$KB_BASE/focus-slack/" command "$HOME/.local/bin/focus-app slack"
gsettings set "$SCHEMA:$KB_BASE/focus-slack/" binding '<Super>s'
gsettings set "$SCHEMA:$KB_BASE/focus-zed/" name    'Focus Zed (editor)'
gsettings set "$SCHEMA:$KB_BASE/focus-zed/" command "$HOME/.local/bin/focus-app zed"
gsettings set "$SCHEMA:$KB_BASE/focus-zed/" binding '<Super>e'

# ─── Clean up stale orphan slots ──────────────────────────────────────────────
# custom4 used to hold the kitty Ctrl+Alt+T binding before we moved to ghostty
# at custom0. It's dormant but lingering in dconf — remove so future audits
# don't get confused.
dconf reset -f "$KB_BASE/custom4/" 2>/dev/null || true

# ─── Register all owned slots ─────────────────────────────────────────────────
# Build the array from the explicit list above. ANY future custom binding must
# be added to BOTH a new slot block AND this array literal.
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['$KB_BASE/custom0/', '$KB_BASE/custom1/', '$KB_BASE/custom2/', '$KB_BASE/cockpit/', '$KB_BASE/custom5/', '$KB_BASE/custom6/', '$KB_BASE/custom7/', '$KB_BASE/mon-l/', '$KB_BASE/mon-a/', '$KB_BASE/mon-s/', '$KB_BASE/mon-d/', '$KB_BASE/focus-mon-a/', '$KB_BASE/focus-mon-s/', '$KB_BASE/focus-mon-d/', '$KB_BASE/focus-mon-1/', '$KB_BASE/focus-mon-2/', '$KB_BASE/focus-mon-3/', '$KB_BASE/focus-zen/', '$KB_BASE/focus-zen-b/', '$KB_BASE/focus-obsidian/', '$KB_BASE/focus-slack/', '$KB_BASE/focus-zed/']"

# Adding NEW custom-keybinding slots (not just editing existing ones) requires
# gsd-media-keys to re-read its config. It caches the slot list at startup and
# doesn't dynamically pick up new entries. We kill it AND explicitly respawn
# it — gnome-session does NOT auto-restart gsd-media-keys after a killall, so
# without an explicit relaunch you lose F12 lock + Super+L + every custom
# binding until next login. Learned this the hard way 2026-06-02.
echo "→ gsettings: restarting gsd-media-keys to pick up any new slots"
killall gsd-media-keys 2>/dev/null && sleep 0.5 || true
setsid -f /usr/libexec/gsd-media-keys </dev/null >/dev/null 2>&1 &
sleep 0.3
pgrep -f /usr/libexec/gsd-media-keys >/dev/null && echo "  gsd-media-keys back up" || echo "  WARN: gsd-media-keys failed to respawn"

echo "→ gsettings: done"
