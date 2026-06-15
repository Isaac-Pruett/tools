#!/usr/bin/env bash
# install.sh — symlink lks-dev-env dotfiles to the correct locations
# Supports: Linux (X11/Wayland), macOS, Windows WSL
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Detect OS ────────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Linux*)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      PLATFORM="wsl"
    else
      PLATFORM="linux"
    fi
    ;;
  Darwin*) PLATFORM="mac" ;;
  *)       PLATFORM="unknown" ;;
esac

echo "platform: $PLATFORM"

# ─── Create directories ────────────────────────────────────────────────────────
mkdir -p \
  "$HOME/.config/kitty" \
  "$HOME/.local/bin" \
  "$HOME/.tmux"

# ─── Symlink dotfiles ──────────────────────────────────────────────────────────
ln -sf "$REPO/zsh/zshrc"              "$HOME/.zshrc"
ln -sf "$REPO/zsh/zshenv"             "$HOME/.zshenv"
ln -sf "$REPO/kitty/kitty.conf"       "$HOME/.config/kitty/kitty.conf"
ln -sf "$REPO/tmux/tmux.conf"         "$HOME/.tmux.conf"
ln -sf "$REPO/tmux/keybinds.md"       "$HOME/.tmux/keybinds.md"
ln -sf "$REPO/starship/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$REPO/scripts/sessionizer"              "$HOME/.local/bin/sessionizer"
ln -sf "$REPO/scripts/session-picker"           "$HOME/.local/bin/session-picker"
ln -sf "$REPO/scripts/gst"                      "$HOME/.local/bin/gst"
ln -sf "$REPO/scripts/focus-app"                "$HOME/.local/bin/focus-app"
ln -sf "$REPO/scripts/restore-display-layout"   "$HOME/.local/bin/restore-display-layout"
ln -sf "$REPO/scripts/resume-display-restore"   "$HOME/.local/bin/resume-display-restore"
ln -sf "$REPO/scripts/sync-to-host"             "$HOME/.local/bin/sync-to-host"
ln -sf "$REPO/scripts/tx-remote"                "$HOME/.local/bin/tx-remote"
ln -sf "$REPO/scripts/ctx"                      "$HOME/.local/bin/ctx"
ln -sf "$REPO/scripts/tx-mk"                    "$HOME/.local/bin/tx-mk"
ln -sfn "$REPO/lazyvim"                         "$HOME/.config/nvim"
mkdir -p "$HOME/.config/ghostty"
ln -sf "$REPO/ghostty/config"                   "$HOME/.config/ghostty/config"
chmod +x "$HOME/.local/bin/sessionizer" "$HOME/.local/bin/session-picker" "$HOME/.local/bin/gst" "$HOME/.local/bin/focus-app" "$HOME/.local/bin/restore-display-layout" "$HOME/.local/bin/resume-display-restore" "$HOME/.local/bin/sync-to-host" "$HOME/.local/bin/tx-remote" "$HOME/.local/bin/ctx" "$HOME/.local/bin/tx-mk"

# ─── Seed ~/.config/sessions/ if empty ────────────────────────────────────────
# Multi-file layout: ~/.config/sessions/<NN>-<scope>.toml. Lower-numbered files
# win on name conflict (canon beats scratch beats local). Picker globs *.toml.
mkdir -p "$HOME/.config/sessions"
if [ -z "$(ls -A "$HOME/.config/sessions" 2>/dev/null)" ]; then
  cp "$REPO/scripts/sessions.toml.example" "$HOME/.config/sessions/10-canon.toml"
  echo "seeded ~/.config/sessions/10-canon.toml from template — edit before first launch"
fi
# Migrate the legacy single ~/.config/sessions.toml on first run (one-shot).
if [ -f "$HOME/.config/sessions.toml" ] && [ ! -f "$HOME/.config/sessions/_migrated-legacy.toml" ]; then
  cp "$HOME/.config/sessions.toml" "$HOME/.config/sessions/_migrated-legacy.toml"
  echo "migrated legacy ~/.config/sessions.toml → ~/.config/sessions/_migrated-legacy.toml"
fi

# ─── Seed ~/.tmux.conf.local if missing ──────────────────────────────────────
# This file holds machine-local SSH-into-remote bindings (private hostnames)
# and is intentionally NOT tracked in the repo. Copy never overwrites an
# existing user-edited copy.
if [ ! -f "$HOME/.tmux.conf.local" ]; then
  cp "$REPO/tmux/tmux.conf.local.example" "$HOME/.tmux.conf.local"
  echo "seeded ~/.tmux.conf.local from template — add your remote-host bindings"
fi

# ─── Platform notes ────────────────────────────────────────────────────────────
echo ""
echo "dotfiles linked from $REPO"
echo ""

case "$PLATFORM" in
  wsl)
    echo "note: tmux clipboard uses OSC 52 → set-clipboard on. WSL needs a terminal that honors OSC 52 (Windows Terminal, wezterm, ghostty)."
    ;;
  mac)
    echo "note: tmux clipboard uses OSC 52 → set-clipboard on. macOS Terminal.app does NOT honor OSC 52 by default; use ghostty/iterm2/wezterm."
    echo "note: kitty shell path uses ~/.nix-profile/bin/zsh — update if using homebrew zsh:"
    echo "  /opt/homebrew/bin/zsh  or  /usr/local/bin/zsh"
    ;;
esac

# ─── Per-machine profile dispatch ─────────────────────────────────────────────
# If profiles/.active-profile points to a profile dir with a setup.sh, run it.
# To activate a profile on a machine:
#   ln -sfn <profile-name> profiles/.active-profile
# Idempotent — safe to skip if no profile is active.
ACTIVE="$REPO/profiles/.active-profile"
if [[ -L "$ACTIVE" ]]; then
  PROFILE_PATH="$(readlink -f "$ACTIVE")"
  if [[ -f "$PROFILE_PATH/setup.sh" ]]; then
    echo ""
    echo "active profile: $(basename "$PROFILE_PATH")"
    bash "$PROFILE_PATH/setup.sh"
  else
    echo "note: profiles/.active-profile points to $PROFILE_PATH but no setup.sh there — skipping"
  fi
fi
