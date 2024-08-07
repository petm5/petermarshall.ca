{ lib, pkgs, ... }: let

  htmlPages = pkgs.callPackage ./build.nix {};

  nginxConf = pkgs.writeText "nginx.conf" ''
    default_type application/octet-stream;
    gzip on;
    gzip_types text/plain;
    daemon off;
    error_log /dev/stdout info;
    http {
      access_log /dev/stdout;
      server {
        listen localhost
        server_name petermarshall.ca
        location / {
          root ${htmlPages};
          expires 10m;
        }
        location ~* \.(jpg|jpeg|gif|svg|png|heif|avif)$ {
            root ${htmlPages};
            access_log off;
            expires 30d;
        }
        error_page 404 /404.html;
      }
    }
  '';

in {

  name = "petermarshall.ca";

  contents = [ pkgs.nginx htmlPages ];

  config = {
    Cmd = [ "${pkgs.nginx}/bin/nginx -c ${nginxConf}" ];
    ExposedPorts = {
      "8000/tcp" = { };
    };
  };

}
