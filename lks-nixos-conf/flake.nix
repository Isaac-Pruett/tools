{
  description = "NixOS workstation — reproducible dev environment";

  inputs = {
    # Stable channel — primary source for everything
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Unstable — used only for packages not yet in 24.11 (cursor, zed)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Zen Browser — not in nixpkgs (reverted); community flake is the NixOS-native approach
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Local sub-flake — provides sticky-fingers (and other portable dev-env packages)
    lks-dev-env.url = "path:../lks-dev-env";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, zen-browser, lks-dev-env, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Unstable pkgs with unfree allowed, passed as specialArgs so
      # configuration.nix can selectively pull from it
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.workstation = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit pkgs-unstable;
          zen-browser-pkg = zen-browser.packages.${system}.default;
          sticky-fingers-pkg  = lks-dev-env.packages.${system}.sticky-fingers;
        };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          ./sticky-fingers.nix
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = (with pkgs; [

          # --- Shell & terminal ---
          # [UBUNTU/GNOME]  kitty via nix profile on current machine
          # [NIXOS/WAYLAND] kitty stays; uncomment alacritty below to swap
          tmux
          kitty
          # alacritty   # [NIXOS/WAYLAND] minimal Wayland-native alternative
          bash
          zsh
          zsh-autosuggestions
          zsh-syntax-highlighting
          starship
          less

          # --- Resource monitors & system info ---
          btop
          lsof
          pciutils
          usbutils
          dmidecode
          lshw

          # --- File & text utilities ---
          bat
          eza
          yazi
          tree
          ncdu
          file
          unzip
          zip
          xz
          gzip
          bzip2

          # --- Search & navigation ---
          ripgrep
          fd
          fzf
          zoxide
          atuin

          # --- Network & security ---
          curl
          wget
          rsync
          socat
          openbsd-netcat
          tcpdump
          openssl
          iproute2
          net-tools
          tailscale

          # --- JSON & data ---
          jq

          # --- Version control ---
          git
          delta
          lazygit
          glab

          # --- Editors ---
          helix

          # --- Network tools ---
          nmap
          iw

          # --- Compression ---
          zstd

          # --- Protobuf ---
          protobuf

          # --- Wayland / Sway desktop stack ---
          # [NIXOS/WAYLAND ONLY] — not applicable on Ubuntu/GNOME
          waybar
          wofi
          mako
          swaylock
          swayidle
          grim
          slurp
          kanshi
          wl-clipboard    # primary clipboard on Wayland
          xdg-utils

          # --- Clipboard tools ---
          xclip           # [UBUNTU/GNOME] X11 clipboard for tmux copy pipe
                          # [NIXOS/WAYLAND] only needed for XWayland apps; wl-clipboard covers the rest
          copyq           # clipboard manager — works on both platforms

          # --- Build tools ---
          gnumake
          cmake
          pkg-config
          gcc
          binutils
          ccache
          ninja

          # --- Debug & profiling ---
          gdb
          strace
          valgrind

          # --- Python ---
          python3
          uv

          # --- Nix dev tooling ---
          nixd
          nix-output-monitor

          # --- Unfree applications ---
          vscode
          google-chrome
          slack
          spotify
          obsidian

        ]) ++ (with pkgs-unstable; [
          cursor
          zed-editor
        ]);
      };
    };
}
