{ stdenv, lib, pkgs, siteName, rev, ... }: let
  node-addon-api = pkgs.callPackage ./node-addon-api {};
in pkgs.buildNpmPackage {
  name = siteName;
  src = ../site;
  npmDepsHash = "sha256-kmQJeLfT7jp23ZuExHA/g72W7MFI1npGZ0gFFEf9QcY=";
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
  GIT_REVISION = rev;
  buildPhase = ''
    npx @11ty/eleventy --output=$out
  '';
}
