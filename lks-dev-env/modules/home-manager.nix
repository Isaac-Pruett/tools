# lks-dev-env home-manager module — declarative dotfile install.
#
# Use this on any home-manager-managed host (NixOS, nix-darwin, standalone HM)
# to get the same dotfile symlinks install.sh creates, but reproducibly:
#
#   # flake.nix (consumer)
#   inputs.lks-dev-env.url = "github:Isaac-Pruett/tools?dir=lks-dev-env&ref=lukas";
#     # or "path:/home/USER/tools/lks-dev-env" for local dev
#
#   # home.nix (consumer)
#   imports = [ inputs.lks-dev-env.homeManagerModules.default ];
#
# Symlinks point at the user's WORKING COPY of the dev-env (resolved via
# config.home.homeDirectory + lksDevEnv.path), NOT a nix-store snapshot. That
# means edits + sync-to-host show up immediately without rebuilding HM. This is
# the canonical use case for config.lib.file.mkOutOfStoreSymlink.
#
# Override the location if you keep the dev-env elsewhere:
#   lksDevEnv.path = "${config.home.homeDirectory}/.local/share/lks-dev-env";

{ config, lib, ... }:

let
  cfg = config.lksDevEnv;
in {
  options.lksDevEnv = {
    path = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/tools/lks-dev-env";
      description = "Absolute path to the lks-dev-env working copy on this host.";
    };

    enableTmux = lib.mkEnableOption "tmux dotfile symlinks (.tmux.conf, keybinds.md)" // { default = true; };
    enableZsh = lib.mkEnableOption "zsh dotfile symlinks (.zshrc, .zshenv)" // { default = true; };
    enableStarship = lib.mkEnableOption "starship config symlink" // { default = true; };
    enableGhostty = lib.mkEnableOption "ghostty config symlink" // { default = true; };
    enableHelix = lib.mkEnableOption "helix config symlinks" // { default = true; };
    enableVim = lib.mkEnableOption "vim config symlink (.vimrc)" // { default = true; };
    enableNvim = lib.mkEnableOption "neovim (lazyvim) config symlink" // { default = false; };
  };

  config = let
    link = src: { source = config.lib.file.mkOutOfStoreSymlink "${cfg.path}/${src}"; };
  in {
    home.file = lib.mkMerge [
      (lib.mkIf cfg.enableTmux {
        ".tmux.conf"        = link "tmux/tmux.conf";
        ".tmux/keybinds.md" = link "tmux/keybinds.md";
      })
      (lib.mkIf cfg.enableZsh {
        ".zshrc"  = link "zsh/zshrc";
        ".zshenv" = link "zsh/zshenv";
      })
      (lib.mkIf cfg.enableStarship {
        ".config/starship.toml" = link "starship/starship.toml";
      })
      (lib.mkIf cfg.enableGhostty {
        ".config/ghostty/config" = link "ghostty/config";
      })
      (lib.mkIf cfg.enableHelix {
        ".config/helix/config.toml" = link "helix/config.toml";
        ".config/helix/themes/monokai-amoled.toml" = link "helix/themes/monokai-amoled.toml";
      })
      (lib.mkIf cfg.enableVim {
        ".vimrc" = link "vim/vimrc";
      })
      (lib.mkIf cfg.enableNvim {
        ".config/nvim" = link "lazyvim";
      })
    ];
  };
}
