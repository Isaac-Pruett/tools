#!/usr/bin/env bash
# bootstrap.sh — post nixos-rebuild steps for a fresh lks NixOS machine
# Run once after: nixos-rebuild switch
set -e

echo "==> lks NixOS bootstrap"
echo ""

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ─── 1. Dotfiles ──────────────────────────────────────────────────────────────
echo "[1/4] Linking dotfiles from lks-dev-env..."
bash "$TOOLS_DIR/lks-dev-env/install.sh"

# ─── 2. TPM (tmux plugin manager) ────────────────────────────────────────────
echo ""
echo "[2/4] Bootstrapping TPM..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo "      TPM cloned"
else
  echo "      TPM already present, skipping"
fi

# ─── 3. Install tmux plugins headlessly ───────────────────────────────────────
echo ""
echo "[3/4] Installing tmux plugins..."
"$HOME/.tmux/plugins/tpm/bin/install_plugins" && echo "      plugins installed"

# ─── 4. Remind user of manual steps ───────────────────────────────────────────
echo ""
echo "[4/4] Manual steps still required:"
echo ""
echo "  passwd \$USER                   set your user password"
echo "  sudo tailscale up              authenticate to tailnet"
echo "  ssh-keygen -t ed25519          generate SSH key (or transfer existing)"
echo "  nixos-generate-config          regenerate hardware-configuration.nix"
echo "                                 then copy to lks-nixos-conf/ and rebuild"
echo ""
echo "  ~/.secrets                     create with any API keys / env vars:"
echo "    export ANTHROPIC_API_KEY=..."
echo "    export OPENAI_API_KEY=..."
echo ""
echo "bootstrap done"
