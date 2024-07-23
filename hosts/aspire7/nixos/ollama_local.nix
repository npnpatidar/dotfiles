{ config, ... }: {
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "0.0.0.0";
  };

  virtualisation = {
    oci-containers = {
      containers = {
        open-webui = {
          image = "ghcr.io/open-webui/open-webui:main";
          autoStart = true;
          ports = [
            "127.0.0.1:8080:8080"
          ];
          volumes = [
            "open-webui:/app/backend/data"
          ];
          environment = {
            OLLAMA_BASE_URL = "http://127.0.0.1:11434";
            ANONYMIZED_TELEMETRY = "False";
          };
          environmentFiles = [ config.age.secrets.open_webui_environment_file.path ];
          extraOptions = [
            "--network=host"
            "--add-host=host.containers.internal:host-gateway"
          ];
        };
      };
    };
  };

}
