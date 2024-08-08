{
  description = "petermarshall.ca";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
          ];
        };
        packages = rec {
          petms-website = pkgs.callPackage ./pkgs/petms-website.nix {};
          petms-website-docker = pkgs.callPackage  ./pkgs/docker-webserver.nix { htmlPages = petms-website; };
          default = petms-website;
        };
      }
    );
}
