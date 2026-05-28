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
        neovim   = pkgs.neovim;
        nodejs   = pkgs.nodejs_22;
        clang-tools = pkgs.clang-tools;
        lazygit  = pkgs.lazygit;
        delta    = pkgs.delta;
        socat    = pkgs.socat;
        minicom  = pkgs.minicom;
        btop     = pkgs.btop;
        nethogs  = pkgs.nethogs;

        # Networking diagnostics
        nmap        = pkgs.nmap;        # port scanning + host discovery
        wireshark   = pkgs.wireshark;   # GUI packet inspector (also provides tshark)
        tcpdump     = pkgs.tcpdump;     # CLI packet capture
        mtr         = pkgs.mtr;         # traceroute + ping combined
        iperf3      = pkgs.iperf3;      # bandwidth testing

        # Pen-testing / wireless
        aircrack-ng = pkgs.aircrack-ng; # wifi suite — airodump-ng, airmon-ng, aireplay-ng
        hydra       = pkgs.thc-hydra;   # auth brute-forcer
        gobuster    = pkgs.gobuster;    # web/dir/dns enumeration
        masscan     = pkgs.masscan;     # very fast port scanner

        sticky-fingers = pkgs.rustPlatform.buildRustPackage {
          pname   = "sticky-fingers";
          version = "0.1.0";
          src     = ./sticky-fingers;
          cargoLock.lockFile = ./sticky-fingers/Cargo.lock;
          # Strip + LTO already in Cargo.toml release profile.
          meta.description = "Hyper-lightweight evdev keystroke logger";
        };
        zsh-autosuggestions     = pkgs.zsh-autosuggestions;
        zsh-syntax-highlighting = pkgs.zsh-syntax-highlighting;
        wl-clipboard            = pkgs.wl-clipboard;
        xsel                    = pkgs.xsel;
      };

      devShells.default = pkgs.mkShell {
        packages = builtins.attrValues self'.packages;
      };

    };
  };
}
