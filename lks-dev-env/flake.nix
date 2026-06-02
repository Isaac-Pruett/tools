{
  description = "lks portable dev environment";

  inputs = {
    nixpkgs.url    = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" "aarch64-linux" ];

    perSystem = { pkgs, self', ... }:
    let
      core       = import ./modules/core.nix       { inherit pkgs; };
      shell      = import ./modules/shell.nix      { inherit pkgs; };
      editors    = import ./modules/editors.nix    { inherit pkgs; };
      system     = import ./modules/system.nix     { inherit pkgs; };
      networking = import ./modules/networking.nix { inherit pkgs; };
      pentest    = import ./modules/pentest.nix    { inherit pkgs; };
      personal   = import ./modules/personal.nix   { inherit pkgs; };
    in
    {
      # Every module's outputs are surfaced as individual packages so
      # `nix profile install path:#<name>` keeps working unchanged.
      packages =
        core // shell // editors // system // networking // pentest // personal;

      # Composable per-machine profiles. Compose via // — later modules can
      # override earlier keys if needed.
      devShells = {
        default    = pkgs.mkShell { packages = builtins.attrValues self'.packages; };
        minimal    = pkgs.mkShell { packages = builtins.attrValues (core // shell); };
        dev        = pkgs.mkShell { packages = builtins.attrValues (core // shell // editors // system); };
        networking = pkgs.mkShell { packages = builtins.attrValues (core // shell // networking); };
        pentest    = pkgs.mkShell { packages = builtins.attrValues (core // shell // networking // pentest); };
      };
    };
  };
}
