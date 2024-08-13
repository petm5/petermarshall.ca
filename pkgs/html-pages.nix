{ stdenv, lib, pkgs, siteName, ... }: let
  node-addon-api = pkgs.callPackage ./node-addon-api {};
in pkgs.buildNpmPackage {
  name = siteName;
  src = ../site;
  npmDepsHash = "sha256-3eHYAqrxQ8W+p4YrG5lCnt8UHbmJV0SvJpsWqbzD4NY=";
  buildInputs = with pkgs; [
    nodejs_22
    vips
    libsecret
    pixman
    cairo
    pango
    node-addon-api
  ];
  npmPackFlags = [ "--ignore-scripts" ];
  dontNpmInstall = true;
  buildPhase = ''
    npx @11ty/eleventy --output=$out
  '';
}
