{ config, pkgs, ... }:
{
  virtualisation = {
    oci-containers.containers = {
      n8n = {
        image = "n8nio/n8n:next";
        environment = {
          WEBHOOK_URL = "https://n8n.naresh.world/";
          GENERIC_TIMEZONE = "Asia/Kolkata";
          NODE_FUNCTION_ALLOW_EXTERNAL = "*";
          NODE_FUNCTION_ALLOW_BUILTIN = "*";
          N8N_TEMPLATES_ENABLED = "true";
          N8N_DIAGNOSTICS_ENABLED = "false";
          N8N_VERSION_NOTIFICATIONS_ENABLED = "false";
        };
        volumes = [ "n8n_data:/home/node" ];
        ports = [ "5678:5678" ];
        autoStart = true;
        extraOptions = [
          "--network=slirp4netns:allow_host_loopback=true"
          "--add-host=n8n.local:10.0.2.2"
        ];
      };

    };
  };
  services.nginx = {
    virtualHosts."n8n.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:5678";
        proxyWebsockets = true;
      };
    };
  };
}
