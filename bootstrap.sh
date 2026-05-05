#!/usr/bin/env bash
# bootstrap.sh — set up lks terminal environment on any nix-capable machine
#
# usage:
#   bash bootstrap.sh           # terminal env only
#   bash bootstrap.sh --ubuntu  # terminal env + ubuntu-specific (zed, local aliases)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE="path:$REPO/lks-dev-env"
UBUNTU=false
[[ "${1:-}" == "--ubuntu" ]] && UBUNTU=true

# ─── Output helpers ───────────────────────────────────────────────────────────
log()  { printf '\n── %s\n' "$*"; }
ok()   { printf '  ✓ %s\n' "$*"; }
info() { printf '  · %s\n' "$*"; }

# ─── 1. Nix ───────────────────────────────────────────────────────────────────
log "nix"
if ! command -v nix &>/dev/null; then
  echo ""
  echo "  nix not found — install it first, then re-run this script:"
  echo "  https://install.determinate.systems/nix"
  exit 1
fi
ok "nix $(nix --version | awk '{print $NF}')"

# ─── 2. Tools ─────────────────────────────────────────────────────────────────
log "tools"

# install a package from the flake if its binary or file is not already reachable
nix_install() {
  local label=$1 pkg=$2
  shift 2
  for check in "$@"; do
    local type="${check%%:*}" val="${check#*:}"
    case "$type" in
      cmd)  command -v "$val" &>/dev/null        && { info "$label already in PATH"; return 0; } ;;
      file) [[ -e "$val" ]]                      && { info "$label already present"; return 0; } ;;
    esac
  done
  printf '  installing %s...\n' "$label"
  nix profile install "$FLAKE#$pkg"
  ok "$label installed"
}

# shells & prompt
nix_install "zsh"                     zsh                     cmd:zsh
nix_install "starship"                starship                cmd:starship
nix_install "zsh-autosuggestions"     zsh-autosuggestions     \
  "file:$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "file:/run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
nix_install "zsh-syntax-highlighting" zsh-syntax-highlighting \
  "file:$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "file:/run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# terminal & multiplexer
nix_install "kitty"                   kitty                   cmd:kitty
nix_install "tmux"                    tmux                    cmd:tmux

# editors
nix_install "helix"                   helix                   cmd:hx

# cli tools
nix_install "fzf"                     fzf                     cmd:fzf
nix_install "ripgrep"                 ripgrep                 cmd:rg
nix_install "fd"                      fd                      cmd:fd
nix_install "bat"                     bat                     cmd:bat
nix_install "eza"                     eza                     cmd:eza
nix_install "yazi"                    yazi                    cmd:yazi
nix_install "zoxide"                  zoxide                  cmd:zoxide
nix_install "atuin"                   atuin                   cmd:atuin
nix_install "lazygit"                 lazygit                 cmd:lazygit
nix_install "delta"                   delta                   cmd:delta
nix_install "socat"                   socat                   cmd:socat
nix_install "minicom"                 minicom                 cmd:minicom
nix_install "btop"                    btop                    cmd:btop
nix_install "wl-clipboard"            wl-clipboard            cmd:wl-copy
nix_install "xsel"                    xsel                    cmd:xsel

# ─── 3. Configs ───────────────────────────────────────────────────────────────
log "configs"
bash "$REPO/lks-dev-env/install.sh"
ok "terminal configs linked"

if $UBUNTU; then
  bash "$REPO/lks-ubuntu/install.sh"
  ok "ubuntu configs linked"
fi

# ─── 4. TPM (tmux plugin manager) ────────────────────────────────────────────
log "tmux plugins"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
  info "tpm already installed"
else
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  ok "tpm cloned — open tmux and press prefix + I to install plugins"
fi

# ─── 5. Shell ─────────────────────────────────────────────────────────────────
log "shell"
ZSH_BIN="$(command -v zsh || echo "$HOME/.nix-profile/bin/zsh")"
if [[ "$SHELL" == *zsh* ]]; then
  info "already using zsh ($SHELL)"
else
  if ! grep -qF "$ZSH_BIN" /etc/shells 2>/dev/null; then
    echo "$ZSH_BIN" | sudo tee -a /etc/shells > /dev/null
  fi
  chsh -s "$ZSH_BIN"
  ok "shell changed to zsh — restart your terminal"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
printf '\n── done\n'
printf '  configs live in %s\n' "$REPO/lks-dev-env"
printf '  re-run anytime — already-installed tools are skipped\n\n'
