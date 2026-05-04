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
chmod +x "$HOME/.local/bin/sessionizer"

# ─── Platform notes ────────────────────────────────────────────────────────────
echo ""
echo "dotfiles linked from $REPO"
echo ""

case "$PLATFORM" in
  linux)
    echo "note: tmux clipboard uses xclip (X11). On Wayland swap xclip for wl-copy in tmux/tmux.conf"
    ;;
  wsl)
    echo "note: tmux clipboard uses xclip. In WSL you may want clip.exe instead:"
    echo "  sed -i 's/xclip -selection clipboard -i/clip.exe/g' tmux/tmux.conf"
    ;;
  mac)
    echo "note: tmux clipboard uses xclip — not available on macOS. Swap for pbcopy in tmux/tmux.conf:"
    echo "  sed -i '' 's/xclip -selection clipboard -i/pbcopy/g' tmux/tmux.conf"
    echo "  sed -i '' 's/xclip -selection clipboard -o/pbpaste/g' tmux/tmux.conf"
    echo ""
    echo "note: kitty shell path uses ~/.nix-profile/bin/zsh — update if using homebrew zsh:"
    echo "  /opt/homebrew/bin/zsh  or  /usr/local/bin/zsh"
    ;;
esac
