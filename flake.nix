{
  description = "Isaac-Pruett's personal development packages flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    tv.url = "./tv";
    helix.url = "./helix";
  };


  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    perSystem = { pkgs, self', system, lib, ... }:
      let
        subPkgs = lib.mergeAttrsList (
          map (x: x.packages.${system}) (with inputs; [
            tv
            helix
          ])
        );
      in {

        packages = subPkgs // {
          default = pkgs.symlinkJoin {
            name = "mypkgs";
            paths = builtins.attrValues subPkgs;
          };
        };


        devShells.default = pkgs.mkShell {
          packages = builtins.attrValues subPkgs;
        };
      };
  };
}
