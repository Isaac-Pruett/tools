{ config, pkgs, pkgs-unstable, zen-browser-pkg, lib, ... }:

{
  # ─── Boot ─────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ─── Networking ───────────────────────────────────────────────────────────
  # Change hostName per machine
  networking.hostName = "workstation";
  networking.networkmanager.enable = true;

  # ─── Locale & Time ────────────────────────────────────────────────────────
  # Change timeZone as needed (e.g. "America/Los_Angeles", "Europe/London")
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  # ─── Users ────────────────────────────────────────────────────────────────
  users.users.bolt = {
    isNormalUser = true;
    description  = "Bolt";
    extraGroups  = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell        = pkgs.bash;
    # Set password on first boot: passwd bolt
  };

  # ─── Nix Settings ─────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features  = [ "nix-command" "flakes" ];
    auto-optimise-store    = true;
    # Allow your user to manage nix without sudo
    trusted-users          = [ "root" "bolt" ];
  };

  # Required for unfree packages: Cursor, VS Code, Chrome, Slack, Spotify, Obsidian
  nixpkgs.config.allowUnfree = true;

  # ─── Wayland / Sway ───────────────────────────────────────────────────────
  programs.sway = {
    enable = true;
    # Wraps sway so GTK apps pick up the correct theme/cursor
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export NIXOS_OZONE_WL=1
    '';
  };

  # XWayland for X11 apps that don't have Wayland support yet
  programs.xwayland.enable = true;

  # XDG portals: screen share, file pickers, and app sandboxing under Wayland
  xdg.portal = {
    enable       = true;
    wlr.enable   = true;  # needed for wlroots-based compositors (sway)
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ─── Graphics ─────────────────────────────────────────────────────────────
  # Hardware-specific GPU drivers (AMD iGPU, NVIDIA dGPU, etc.) belong in
  # hardware-configuration.nix — add them per machine with nixos-generate-config
  # or manually. Keeping this section hardware-agnostic.
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;  # needed for Steam/32-bit apps and some Electron apps
  };

  # ─── Audio (PipeWire) ─────────────────────────────────────────────────────
  # PipeWire replaces PulseAudio + JACK; handles all audio on modern systems
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;  # drop-in PulseAudio compatibility
  };
  # rtkit provides realtime scheduling priority for PipeWire
  security.rtkit.enable = true;

  # ─── Display Manager (greetd + tuigreet) ──────────────────────────────────
  # greetd is a lightweight, Wayland-native session manager. tuigreet gives a
  # simple terminal login screen that drops straight into sway.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      user    = "greeter";
    };
  };

  # ─── Security ─────────────────────────────────────────────────────────────
  security.polkit.enable = true;
  # PAM entry so swaylock can authenticate via PAM (required for it to unlock)
  security.pam.services.swaylock = { };

  # ─── Services ─────────────────────────────────────────────────────────────

  # Tailscale — mesh VPN daemon
  # After first boot, run: sudo tailscale up
  # This opens a browser auth URL to connect this machine to your tailnet.
  # Optionally set authKeyFile to a file containing a pre-auth key for headless
  # auth: services.tailscale.authKeyFile = "/run/secrets/tailscale-key";
  services.tailscale.enable = true;
  # Allow the tailscale subnet router / exit-node traffic through the firewall
  networking.firewall.checkReversePath = "loose";

  # OpenSSH (optional but useful for remote access via tailnet)
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;  # key-based auth only
  };

  # ─── tmux ─────────────────────────────────────────────────────────────────
  # Installs tmux system-wide. Config is deployed separately via lks-dev-env/install.sh
  # which symlinks lks-dev-env/tmux/tmux.conf → ~/.tmux.conf
  # TPM plugins still live in ~/.tmux/plugins/ — bootstrap once per user:
  #   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  #   tmux source ~/.tmux.conf  (then prefix + I to install plugins)
  programs.tmux = {
    enable        = true;
    sensibleOnTop = false;
  };

  # ─── direnv ───────────────────────────────────────────────────────────────
  # System-level direnv + nix-direnv: enables per-project .envrc / flake shells
  programs.direnv = {
    enable           = true;
    nix-direnv.enable = true;
  };

  # ─── Fonts ────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    liberation_ttf
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];

  # ─── Environment Variables ────────────────────────────────────────────────
  environment.sessionVariables = {
    # Tell Electron/Chrome/etc. to use Wayland natively
    NIXOS_OZONE_WL   = "1";
    MOZ_ENABLE_WAYLAND = "1";
    # Preferred editor (change to "nvim" or "code" if preferred)
    EDITOR           = "hx";
    VISUAL           = "hx";
  };

  # ─── System Packages ──────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [

    # --- Shell & terminal ---
    # [UBUNTU/GNOME]  kitty installed via `nix profile install` on the current machine.
    # [NIXOS/WAYLAND] kitty stays as primary; alacritty below is the Wayland-native minimal
    #                 alternative — uncomment if you prefer it on Sway.
    # tmux — managed by programs.tmux above; listed here only for reference (removed to avoid duplicate)
    # sessionizer — deployed via lks-dev-env/install.sh → ~/.local/bin/sessionizer
    kitty               # GPU-accelerated terminal, Catppuccin Mocha — works on both platforms
    # alacritty         # [NIXOS/WAYLAND] minimal Wayland-native alternative; uncomment to swap
    bash
    zsh                 # default shell — bash-compatible superset
    zsh-autosuggestions # fish-style ghost-text autocomplete
    zsh-syntax-highlighting # real-time command coloring (red=invalid, green=valid)
    starship            # Rust prompt: git status, lang versions, ~5ms startup
    less

    # --- Resource monitors & system info ---
    btop
    lsof
    pciutils            # lspci
    usbutils            # lsusb
    dmidecode
    lshw

    # --- File & text utilities ---
    bat                 # cat replacement with syntax highlighting
    eza                 # ls replacement: icons, git status, tree view
    yazi                # TUI file manager with image preview
    tree
    ncdu                # interactive disk usage
    file
    unzip
    zip
    xz
    gzip
    bzip2

    # --- Search & navigation ---
    ripgrep             # rg: fast grep
    fd                  # fast find alternative
    fzf                 # fuzzy finder (Ctrl+T files, Alt+C cd)
    zoxide              # smart cd: z <partial> jumps to frecent dirs (Rust)
    atuin               # shell history in SQLite: fuzzy Ctrl+R, syncable (Rust)

    # --- Network & security ---
    curl
    wget
    rsync
    socat
    openbsd-netcat      # nc (replaces netcat-openbsd)
    tcpdump
    openssl
    iproute2
    net-tools           # ifconfig, netstat, etc.
    tailscale           # CLI companion to the tailscaled service

    # --- JSON & data ---
    jq

    # --- Version control ---
    git
    delta               # git diff pager (was git-delta / gitAndTools.delta)
    lazygit             # TUI git client: stage hunks, branch, rebase interactively
    glab                # GitLab CLI

    # --- Editors ---
    helix

    # --- Network tools ---
    nmap
    iw                  # wireless interface configuration

    # --- Compression ---
    zstd

    # --- Protobuf ---
    protobuf            # provides protoc compiler

    # --- Wayland / Sway desktop stack ---
    # [NIXOS/WAYLAND ONLY] — not applicable on Ubuntu/GNOME. On Ubuntu the compositor,
    # panel, and notifications are all managed by GNOME; this entire block replaces that.
    waybar              # status bar for sway
    wofi                # Wayland app launcher (replaces GNOME's app grid / rofi)
    mako                # Wayland notification daemon (replaces GNOME notifications)
    swaylock            # screen locker
    swayidle            # idle management (lock after timeout, suspend, etc.)
    grim                # screenshot tool (Wayland native; replaces GNOME screenshot)
    slurp               # region selection helper for grim
    kanshi              # display/output configuration profiles (replaces GNOME displays)
    wl-clipboard        # wl-copy / wl-paste — primary clipboard on Wayland
    xdg-utils           # xdg-open and friends

    # --- Clipboard tools ---
    xclip               # [UBUNTU/GNOME] X11 clipboard — used by tmux copy pipe in .tmux.conf
                        # [NIXOS/WAYLAND] wl-clipboard (above) covers this; xclip only needed
                        #                for XWayland apps that haven't ported to Wayland yet
    copyq               # advanced clipboard manager with GUI + scripting — works on both

    # --- Build tools ---
    gnumake
    cmake
    pkg-config
    gcc
    binutils
    ccache              # compiler cache for faster rebuilds
    ninja               # fast build system (common cmake backend)

    # --- Debug & profiling ---
    gdb
    strace
    valgrind

    # --- Python ---
    python3
    uv                  # fast Python package/project manager (replaces pip/pipx)

    # --- Nix dev tooling ---
    nixd                # Nix language server (for editor LSP support)
    nix-output-monitor  # prettier nix build output (nom)

    # --- Unfree applications ---
    vscode              # Visual Studio Code
    google-chrome       # Google Chrome
    slack               # Slack (snap on current machine → nixpkgs here)
    spotify             # Spotify (snap on current machine → nixpkgs here)
    obsidian            # Obsidian (flatpak on current machine → nixpkgs here)

    zen-browser-pkg     # Zen Browser — via youwen5/zen-browser-flake (not in nixpkgs)

  ] ++ (with pkgs-unstable; [
    # Pulled from unstable because stable 24.11 lags on these release cycles:
    cursor              # Cursor AI code editor
    zed-editor          # Zed editor
  ]);

  # ─── System State Version ─────────────────────────────────────────────────
  # This value pins stateful NixOS module behaviour to the 24.11 defaults.
  # Do NOT change it after first install — it is not a channel selector.
  system.stateVersion = "24.11";
}
