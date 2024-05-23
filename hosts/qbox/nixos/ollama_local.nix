{ ... }: {
  services.ollama = {
    enable = true;
    acceleration = "cuda";
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
          extraOptions = [
            "--network=host"
            "--add-host=host.containers.internal:host-gateway"
          ];
        };
      };
    };
  };

}
