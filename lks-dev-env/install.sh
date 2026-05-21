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
ln -sf "$REPO/scripts/sessionizer"    "$HOME/.local/bin/sessionizer"
ln -sf "$REPO/scripts/clip-copy"      "$HOME/.local/bin/clip-copy"
ln -sf "$REPO/scripts/clip-paste"     "$HOME/.local/bin/clip-paste"
ln -sfn "$REPO/lazyvim"               "$HOME/.config/nvim"
mkdir -p "$HOME/.config/ghostty"
ln -sf "$REPO/ghostty/config"         "$HOME/.config/ghostty/config"
chmod +x "$HOME/.local/bin/sessionizer" "$HOME/.local/bin/clip-copy" "$HOME/.local/bin/clip-paste"

# ─── Platform notes ────────────────────────────────────────────────────────────
echo ""
echo "dotfiles linked from $REPO"
echo ""

case "$PLATFORM" in
  wsl)
    echo "note: tmux clipboard — WSL may need clip.exe. Edit scripts/clip-copy if wl-copy/xsel aren't available."
    ;;
  mac)
    echo "note: tmux clipboard — macOS needs pbcopy/pbpaste. Edit scripts/clip-copy to add a Darwin branch."
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
