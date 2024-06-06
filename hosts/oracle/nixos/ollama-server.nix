{ config, ... }: {
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11343;
  };

  virtualisation = {
    oci-containers = {
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
          environment = {
            OLLAMA_BASE_URL = "http://ollama.local:11343";
            ANONYMIZED_TELEMETRY = "False";
          };
          environmentFiles = [ config.age.secrets.open_webui_environment_file.path ];
          extraOptions = [
            "--network=slirp4netns:allow_host_loopback=true"
            "--add-host=ollama.local:10.0.2.2"
          ];
        };
      };
    };
  };

  services.nginx = {
    virtualHosts."ollama.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = config.age.secrets.htpasswdstandard.path;
      locations."/" = {
        proxyPass = "http://localhost:11343";
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

