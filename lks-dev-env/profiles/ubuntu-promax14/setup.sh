#!/usr/bin/env bash
# ubuntu-promax14 profile setup.
# Sourced (or executed) by the repo-root install.sh when this profile is active.
# Idempotent — safe to re-run any time.

set -e
PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "═══ ubuntu-promax14 profile ═══"
echo ""

# ─── 0. Wrapper shims into ~/.local/bin ───────────────────────────────────────
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
