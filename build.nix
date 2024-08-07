{ stdenv, lib, pkgs, ... }:
let
  nodePackages = pkgs.callPackage ./override.nix {};
in stdenv.mkDerivation {
  name = "petermarshall.ca";
  src = ./.;
  buildInputs = [
    pkgs.nodejs_22
    nodePackages."@11ty/eleventy-canary"
    nodePackages."@11ty/eleventy-img"
    nodePackages.markdown-it
    nodePackages.markdown-it-attrs
    nodePackages.markdown-it-anchor
    # nodePackages.sharp
  ];
  buildPhase = ''
    eleventy --input=. --output=$out
  '';
}
