{ config, ... }: {

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
            OLLAMA_BASE_URL = "http://ollama.local:11434";
            ANONYMIZED_TELEMETRY = "False";
            ENABLE_RAG_WEB_SEARCH = "True";
            RAG_WEB_SEARCH_ENGINE = "duckduckgo";
          };
          environmentFiles = [ config.age.secrets.open_webui_environment_file.path ];
          extraOptions = [
            "--network=slirp4netns:allow_host_loopback=true"
            "--add-host=ollama.local:10.0.2.2"
          ];
        };

        ollama = {
          image = "ollama/ollama";
          autoStart = true;
          ports = [ "11434:11434" ];
          volumes = [ "ollama:/root/.ollama" ];
        };
      };
    };
  };

  services.nginx = {
    virtualHosts."ollama.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = config.age.secrets.htpasswdstandard.path;
      locations."/" = {
        proxyPass = "http://127.0.0.1:11434";
      };
    };
    virtualHosts."chat.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8090";
      };
    };
  };
}

