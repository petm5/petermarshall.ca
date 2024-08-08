{ pkgs, lib, ... }: pkgs.buildNpmPackage {
  name = "node-addon-api";
  packageName = "node-addon-api";
  version = "7.1.0";
  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/node-addon-api/-/node-addon-api-7.1.0.tgz";
    sha512 = "mNcltoe1R8o7STTegSOHdnJNN7s5EUvhoS7ShnTHDyOSd+8H+UdWODq6qSv67PjC8Zc5JRT8+oLAMCr0SIXw7g==";
  };
  npmDepsHash = "sha256-DN/drgiC1EI8qexuXn5HXlbTeSYPyPnHpVHwmh+j/iQ=";
  dontNpmBuild = true;
  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';
}
