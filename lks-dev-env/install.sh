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
ln -sf "$REPO/kitty/kitty.conf"       "$HOME/.config/kitty/kitty.conf"
ln -sf "$REPO/tmux/tmux.conf"         "$HOME/.tmux.conf"
ln -sf "$REPO/tmux/keybinds.md"       "$HOME/.tmux/keybinds.md"
ln -sf "$REPO/starship/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$REPO/scripts/sessionizer"    "$HOME/.local/bin/sessionizer"
ln -sf "$REPO/scripts/clip-copy"      "$HOME/.local/bin/clip-copy"
ln -sf "$REPO/scripts/clip-paste"     "$HOME/.local/bin/clip-paste"
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
