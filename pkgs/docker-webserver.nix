{ lib, pkgs, htmlPages, ... }: let

  nginxConf = pkgs.writeText "nginx.conf" ''
    daemon off;
    error_log /dev/stdout info;
    worker_processes 4;
    user nobody nobody;
    pid /dev/null;
    events {}
    http {
      default_type application/octet-stream;
      access_log /dev/stdout;
      server {
        listen 80;
        index index.html;
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

in pkgs.dockerTools.buildLayeredImage {

  name = "petermarshall.ca";
  tag = "latest";

  contents = [ pkgs.fakeNss pkgs.nginx htmlPages ];

  extraCommands = ''
    mkdir -p tmp/nginx_client_body
    mkdir -p var/log/nginx
  '';

  config = {
    Cmd = [ "${pkgs.nginx}/bin/nginx" "-c" nginxConf ];
    ExposedPorts = {
      "80/tcp" = { };
    };
  };

}
