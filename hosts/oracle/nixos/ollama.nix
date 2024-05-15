{ ... }:
{
  services.ollama = {
    enable = true;
    listenAddress = "0.0.0.0:11434";
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
}

