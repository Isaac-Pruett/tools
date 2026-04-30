# install.ps1 — symlink lks-dev-env dotfiles on Windows (native PowerShell)
# Run from repo root: .\lks-dev-env\install.ps1
# Requires: PowerShell 5+ or PowerShell Core (pwsh)
# Note: tmux and kitty require WSL on Windows — use install.sh inside WSL instead

$REPO = Split-Path -Parent $MyInvocation.MyCommand.Path

# ─── Directories ──────────────────────────────────────────────────────────────
$dirs = @(
    "$env:USERPROFILE\.config\kitty",
    "$env:USERPROFILE\.config",
    "$env:APPDATA\Zed"
)
foreach ($d in $dirs) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
}

# ─── Helper: create symlink (requires admin or Developer Mode on Windows) ──────
function Link($src, $dst) {
    if (Test-Path $dst) { Remove-Item $dst -Force }
    New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
    Write-Host "  linked $dst"
}

# ─── Symlinks ─────────────────────────────────────────────────────────────────
# Kitty (works on Windows natively)
Link "$REPO\kitty\kitty.conf" "$env:USERPROFILE\.config\kitty\kitty.conf"

# Starship
Link "$REPO\starship\starship.toml" "$env:USERPROFILE\.config\starship.toml"

# Zed
Link "$REPO\zed\settings.json" "$env:APPDATA\Zed\settings.json"
Link "$REPO\zed\keymap.json"   "$env:APPDATA\Zed\keymap.json"

# ─── Notes ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "dotfiles linked from $REPO"
Write-Host ""
Write-Host "note: tmux and sessionizer require WSL — run install.sh inside your WSL distro"
Write-Host "note: kitty shell path in kitty.conf defaults to ~/.nix-profile/bin/zsh"
Write-Host "      update to your Windows shell if not using Nix:"
Write-Host "      C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
Write-Host "      or C:\Program Files\Git\bin\bash.exe for Git Bash"
Write-Host ""
Write-Host "note: symlinks on Windows require either:"
Write-Host "      - Developer Mode enabled (Settings > Developer Mode), OR"
Write-Host "      - running this script as Administrator"
