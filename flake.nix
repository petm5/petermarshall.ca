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
        node-addon-api = pkgs.callPackage ./pkgs/node-addon-api {};
        environment = pkgs.buildEnv {
          name = "site-runtime-deps";
          paths = with pkgs; [
            bash
            nodejs
            vips
            libsecret
            pixman
            cairo
            pango
            node-addon-api
          ];
        };
      in rec {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
          ];
        };
        apps.eleventy = let
          runner = pkgs.writeScript "build" ''
            export PATH=${environment}/bin
            cd ./site
            npm install
            npx @11ty/eleventy "$@"
          '';
        in {
          type = "app";
          program = "${runner}";
        };
      }
    );
}
