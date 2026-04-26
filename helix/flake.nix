{
  description = "helix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    perSystem = { pkgs, self', system, lib, ... }: {

      packages = {
        helix = pkgs.helix;
      };

      devShells.default = pkgs.mkShell {
        packages = builtins.attrValues self'.packages;
      };

    };
  };
}
