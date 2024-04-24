{ ... }:

{
  # networking.firewall.allowedTCPPorts = [ 80 443 ];


  services.ollama = {
    enable = true;
    listenAddress = "0.0.0.0:11434";
  };
  #
  # virtualisation.oci-containers = {
  #   backend = "docker";
  #   containers = {
  #     ollama-webui = {
  #       image = "ghcr.io/open-webui/open-webui:git-a481255";
  #       autoStart = true;
  #       ports = [ " 8080:8080" ];
  #       environment = {
  #         OLLAMA_API_BASE_URL = "http://localhost:11434";
  #       };
  #       extraOptions = [
  #         "--network=host"
  #         "--add-host=host.docker.internal:host-gateway"
  #       ];
  #       volumes = [
  #         "/opt/open-webui:/app/backend/data"
  #       ];
  #     };
  #   };
  # };
  #
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers = {
      backend = "podman";
      containers = {
        open-webui = {
          image = "ghcr.io/open-webui/open-webui:main";
          autoStart = true;
          ports = [
            "0.0.0.0:8090:8080"
          ];
          volumes = [
            "open-webui:/app/backend/data"
          ];
          # labels = {
          #   "io.containers.autoupdate" = "registry";
          # };
          environment = {
            OLLAMA_BASE_URL = "http://ollama.local:11434";
            ANONYMIZED_TELEMETRY = "False";
          };
          extraOptions = [
            "--network=slirp4netns:allow_host_loopback=true"
            "--add-host=ollama.local:10.0.2.2"
          ];
        };
      };
    };
  };
  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "naresh@whatisleft.anonaddy.com";
  # };
  #
  services.nginx = {
    # enable = true;
    # recommendedGzipSettings = true;
    # recommendedOptimisation = true;
    # recommendedProxySettings = true;
    virtualHosts."ollama.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:11434";
      };
    };
    virtualHosts."chat.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8090";
      };
    };
  };
}

