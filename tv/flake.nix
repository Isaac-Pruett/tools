{
  description = "television and friends";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    perSystem = { pkgs, self', system, lib, ... }: {

      packages = {
        television = pkgs.television;
        bat = pkgs.bat;
        fd = pkgs.fd;
        ripgrep = pkgs.ripgrep;
        nix-search-tv = pkgs.nix-search-tv;
      };

      # packages = lib.mergeAttrsList (with pkgs; [
      #   television
      #   bat
      #   fd
      #   ripgrep
      #   nix-search-tv
      # ]);

      devShells.default = pkgs.mkShell {
        packages = builtins.attrValues self'.packages;
      };

    };
  };
}
