{ lib, pkgs, siteName, htmlPages, rev, ... }: let

  h2oConf = pkgs.writeText "h2o-config" ''
    hosts:
      "${siteName}":
        listen: &listen
          port: 443
          ssl:
            certificate-file: /keys/${siteName}.crt
            key-file: /keys/${siteName}.key
            minimum-version: TLSv1.3
            ocsp-update-interval: 0
        paths:
          /:
            header.add: "link: </assets/main.${lib.substring 0 7 rev}.css>; rel=preload; as=style"
            header.add: "Strict-Transport-Security: max-age=63072000"
            header.add: "X-Message: secret"
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
    http2-reprioritize-blocking-assets: ON
    compress: ON
    send-informational: all
    send-server-name: OFF
  '';

  runner = pkgs.writeScript "run-h2o" ''
    #!${pkgs.runtimeShell}

    ${pkgs.h2o}/bin/h2o -c ${h2oConf} &

    PID=$!

    trap "kill -SIGQUIT $PID" SIGINT

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
