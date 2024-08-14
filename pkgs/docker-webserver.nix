{ lib, pkgs, siteName, htmlPages, rev, ... }: let

  h2oConf = pkgs.writeText "h2o-config" ''
    hosts:
      "${siteName}":
        listen:
          port: 80
        paths:
          /:
            header.add: "Link: </assets/main.${lib.substring 0 7 rev}.css>; rel=preload; as=stylesheet"
            header.add: "X-Rat-Says: Squeek!"
            header.add: "X-Powered-By: Cheese"
            expires: 10 minutes
            file.dir: ${htmlPages}
          /assets:
            expires: 1 year
            file.mime.settypes:
              "image/jpeg": &image
                  extensions: [ ".jpg", ".jpeg" ]
                  is_compressible: no
              "image/png":
                <<: *image
                extensions: [ ".png" ]
              "image/svg+xml":
                <<: *image
                extensions: [ ".svg" ]
                is_compressible: yes
              "image/avif":
                <<: *image
                extensions: [ ".avif" ]
              "text/css":
                extensions: [ ".css" ]
            file.dir: ${htmlPages}/assets

    user: nobody
    access-log: /dev/stdout
    error-log: /dev/stderr
    compress: ON
    send-server-name: OFF
  '';

  runner = pkgs.writeScript "run-h2o" ''
    #!${pkgs.runtimeShell}

    ${pkgs.h2o}/bin/h2o -c ${h2oConf} &

    PID=$!

    trap "kill -SIGTERM $PID" SIGINT

    wait $PID
  '';

in pkgs.dockerTools.buildLayeredImage {

  name = siteName;
  tag = "latest";

  contents = [ pkgs.fakeNss pkgs.h2o htmlPages ];

  extraCommands = ''
    mkdir -p tmp
  '';

  config = {
    Cmd = [ runner ];
    ExposedPorts = {
      "80/tcp" = { };
    };
  };

}
