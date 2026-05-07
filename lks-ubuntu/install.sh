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

# ─── sticky-fingers (manual sudo step) ────────────────────────────────────────────
# The keystroke logger ships as a flake package + systemd unit in lks-dev-env.
# It needs root for /dev/input access, so installation is gated behind sudo.
# Run these once to enable auto-start on boot:
#
#   sudo nix profile install \
#     --profile /nix/var/nix/profiles/default \
#     "$HOME/tools/lks-dev-env#sticky-fingers"
#
#   sudo install -m 644 \
#     "$HOME/tools/lks-dev-env/systemd/sticky-fingers.service" \
#     /etc/systemd/system/sticky-fingers.service
#
#   sudo systemctl daemon-reload
#   sudo systemctl enable --now sticky-fingers
#
# Verify:   systemctl status sticky-fingers
# Read log: sudo cat /run/sticky-fingers/session.log
# Disable:  sudo systemctl disable --now sticky-fingers
echo ""
echo "sticky-fingers: see install.sh comments to enable the auto-start keystroke logger (manual sudo)"
