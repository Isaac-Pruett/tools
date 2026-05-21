#!/usr/bin/env bash
# ubuntu-promax14 profile setup.
# Sourced (or executed) by the repo-root install.sh when this profile is active.
# Idempotent — safe to re-run any time.

set -e
PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "═══ ubuntu-promax14 profile ═══"
echo ""

# ─── 0a. Wrapper shims into ~/.local/bin ──────────────────────────────────────
# Wrappers needed for this machine (e.g. kitty needs nixGLIntel for OpenGL on
# Ubuntu + nix-installed kitty). Symlinked so they're tracked in the repo.
if [[ -d "$PROFILE_DIR/wrappers" ]]; then
  echo "→ wrappers: symlinking into ~/.local/bin/"
  mkdir -p "$HOME/.local/bin"
  for w in "$PROFILE_DIR/wrappers"/*; do
    [[ -f "$w" ]] || continue
    target="$HOME/.local/bin/$(basename "$w")"
    ln -sfn "$w" "$target"
    echo "  $target → $w"
  done
fi

# ─── 0b. Profile-specific scripts into ~/.local/bin ───────────────────────────
# Helper scripts that this profile owns (e.g. `cockpit` — the 3-window
# multi-monitor launcher for this Dell + Samsung + LG setup).
if [[ -d "$PROFILE_DIR/scripts" ]]; then
  echo "→ scripts: symlinking into ~/.local/bin/"
  mkdir -p "$HOME/.local/bin"
  for s in "$PROFILE_DIR/scripts"/*; do
    [[ -f "$s" ]] || continue
    target="$HOME/.local/bin/$(basename "$s")"
    ln -sfn "$s" "$target"
    echo "  $target → $s"
  done
fi

# ─── 1. apt packages ──────────────────────────────────────────────────────────
echo "→ apt: installing packages from packages.txt"
missing=()
while IFS= read -r pkg; do
  # Skip comments and blanks
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    missing+=("$pkg")
  fi
done < "$PROFILE_DIR/packages.txt"

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "  missing: ${missing[*]}"
  sudo apt-get update
  sudo apt-get install -y "${missing[@]}"
else
  echo "  all already installed"
fi

# ─── 1.5 Ghostty via PPA (auto-updates via apt going forward) ─────────────────
# PPA is community-maintained by Mike Kasberg, recommended by Ghostty's docs.
# Skips entirely if ghostty is already installed.
if ! command -v ghostty >/dev/null 2>&1; then
  echo "→ ghostty: installing via mkasberg/ghostty-ubuntu PPA"
  sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
  sudo apt-get update
  sudo apt-get install -y ghostty
else
  echo "→ ghostty: already installed ($(ghostty +version 2>/dev/null | head -1))"
fi

# ─── 2. Hint-mode navigation (warpd) ──────────────────────────────────────────
if [[ -f "$PROFILE_DIR/hint-nav/install.sh" ]]; then
  echo "→ hint-nav: running install"
  bash "$PROFILE_DIR/hint-nav/install.sh"
fi

# ─── 3. GNOME settings ────────────────────────────────────────────────────────
if [[ -f "$PROFILE_DIR/gsettings.sh" ]]; then
  bash "$PROFILE_DIR/gsettings.sh"
fi

echo ""
echo "═══ ubuntu-promax14 profile: done ═══"
