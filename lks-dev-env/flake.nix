{
  description = "lks portable dev environment";

  inputs = {
    nixpkgs.url    = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" "aarch64-linux" ];

    perSystem = { pkgs, self', ... }: {

      packages = {
        tmux     = pkgs.tmux;
        kitty    = pkgs.kitty;
        starship = pkgs.starship;
        zsh      = pkgs.zsh;
        fzf      = pkgs.fzf;
        ripgrep  = pkgs.ripgrep;
        fd       = pkgs.fd;
        bat      = pkgs.bat;
        eza      = pkgs.eza;
        yazi     = pkgs.yazi;
        zoxide   = pkgs.zoxide;
        atuin    = pkgs.atuin;
        helix    = pkgs.helix;
        lazygit  = pkgs.lazygit;
        delta    = pkgs.delta;
        socat    = pkgs.socat;
        minicom  = pkgs.minicom;
        btop     = pkgs.btop;
        zsh-autosuggestions     = pkgs.zsh-autosuggestions;
        zsh-syntax-highlighting = pkgs.zsh-syntax-highlighting;
      };

      devShells.default = pkgs.mkShell {
        packages = builtins.attrValues self'.packages;
      };

    };
  };
}
