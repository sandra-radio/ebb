{ config, pkgs, inputs, ... }:
let
  ebb = inputs.self.packages.${pkgs.system}.ebb;
in
{
  environment.systemPackages = [
    ebb
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "publicxz@pm.me";
  };

  services = {
    nginx = {
      enable = true;
      virtualHosts."ebb.radio" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:10101/";
          proxyWebsockets = true;
          # Setting mostly taken from:
          # https://wave.h2o.ai/docs/deployment/#behind-nginx-reverse-proxy
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto http;
            proxy_set_header X-NginX-Proxy true;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;

            proxy_redirect off;
          '';
        };
      };
    };
    waved = {
      enable = true;
      package = inputs.self.packages.${pkgs.system}.wave;
    };
  };

  systemd.timers."ebb-update" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "60m";
      OnUnitActiveSec = "60m";
      Unit = "ebb-update.service";
    };
  };

  systemd.services."ebb-update" = {
    script = ''
      set -eu
      ${ebb}/bin/ebb --config=/root/.ebb.rc update KM6RTE
      ${ebb}/bin/ebb --config=/root/.ebb.rc update XE2BC
      ${ebb}/bin/ebb --config=/root/.ebb.rc update W6RDX
      ${ebb}/bin/ebb --config=/root/.ebb.rc update NH6WR
      ${ebb}/bin/ebb --config=/root/.ebb.rc update WM6T
      ${ebb}/bin/ebb --config=/root/.ebb.rc update W6HBR
      ${ebb}/bin/ebb --config=/root/.ebb.rc update AG6MO
      ${ebb}/bin/ebb --config=/root/.ebb.rc update KF6BRC
      ${ebb}/bin/ebb --config=/root/.ebb.rc update KE6VZZ
      ${ebb}/bin/ebb --config=/root/.ebb.rc update NJ6R
      ${ebb}/bin/ebb --config=/root/.ebb.rc update WA6BGS-10
      ${ebb}/bin/ebb --config=/root/.ebb.rc update W6RDX-10
      ${ebb}/bin/ebb --config=/root/.ebb.rc publish
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
