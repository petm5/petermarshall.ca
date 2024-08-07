{pkgs ? import <nixpkgs> {
    inherit system;
}, system ? builtins.currentSystem}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };
in
nodePackages // rec {
  "@11ty/eleventy-img" = nodePackages."@11ty/eleventy-img".override (oldAttrs: {
    nativeBuildInputs = [
      pkgs.pkg-config
      (pkgs.python3.withPackages (ps: [ ps.setuptools ]))
    ];
    buildInputs = with pkgs; [
      vips
      libsecret
      pixman
      cairo
      pango
      nodePackages.node-addon-api
      pkgs.nodePackages.node-gyp
    ];
    dontNpmInstall = false;
    npmFlags = "--cpu=wasm32";
    # preInstall = ''
    #   npm run install --cpu=wasm32 --nodedir=${pkgs.nodejs}
    # '';
  });
}
