{ config, pkgs, ... }:
let
  openvscode-server-port = 3045;
  openvscode-server-host = "127.0.0.1";
in
{
  # environment.systemPackages = [
  #   pkgs.openvscode-server
  # ];

  systemd.services.openvscode-server = {
    description = "OpenVSCode server";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    # path = cfg.extraPackages;
    # environment = cfg.extraEnvironment;
    serviceConfig = {
      ExecStart = ''
        ${pkgs.openvscode-server}/bin/openvscode-server \
          --accept-server-license-terms \
          --host=${openvscode-server-host} \
          --port=${toString openvscode-server-port} \
          --telemetry-level=null \
          --without-connection-token \
      '';
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      # RuntimeDirectory = "/home/naresh/repo/";
      User = "naresh";
      Group = "users";
      Restart = "on-failure";
    };
  };



  age.secrets.vscode_htpassword = {
    file = ../../../secrets/vscode_htpassword.age;
    mode = "770";
    owner = "nginx";
    group = "nginx";
  };
  services.nginx = {
    virtualHosts."code.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = config.age.secrets.vscode_htpassword.path;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3045";
        proxyWebsockets = true;
        extraConfig = ''
          # required when the target is also TLS server with multiple hosts
          proxy_ssl_server_name on;
          # required when the server wants to use HTTP Authentication
          proxy_pass_header Authorization;

          proxy_set_header X-Real-IP          $remote_addr;
          proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto  $scheme;
        '';
      };
    };
  };
}
