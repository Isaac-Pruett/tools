#!/usr/bin/env bash
# install.sh — symlink Ubuntu-specific dotfiles
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Zed config path ──────────────────────────────────────────────────────────
ZED_CONFIG="$HOME/.config/zed"
mkdir -p "$ZED_CONFIG"

# ─── Symlink dotfiles ──────────────────────────────────────────────────────────
ln -sf "$REPO/zed/settings.json" "$ZED_CONFIG/settings.json"
ln -sf "$REPO/zed/keymap.json"   "$ZED_CONFIG/keymap.json"
ln -sf "$REPO/zshrc.local"       "$HOME/.zshrc.local"

echo "ubuntu dotfiles linked from $REPO"
