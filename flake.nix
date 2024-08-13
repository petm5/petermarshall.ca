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
        siteName = "petermarshall.ca";
        rev = "${self.rev or self.dirtyRev or "dirty"}";
      in rec {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
          ];
        };
        packages = rec {
          htmlPages = pkgs.callPackage ./pkgs/html-pages.nix { inherit siteName rev; };
          dockerImage = pkgs.callPackage ./pkgs/docker-webserver.nix { inherit siteName htmlPages rev; };
          default = dockerImage;
        };
        apps.server = let
          runner = pkgs.writeScript "run-docker-image" ''
            ${pkgs.podman}/bin/podman load -i ${packages.dockerImage}
            ${pkgs.podman}/bin/podman run -p 127.0.0.1:8080:443 -v ~/keys:/keys:ro localhost/${siteName}:latest
          '';
        in {
          type = "app";
          program = "${runner}";
        };
      }
    );
}
