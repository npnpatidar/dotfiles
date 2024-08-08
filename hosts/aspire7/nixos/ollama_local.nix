{ config, pkgs, lib, ... }:

let
  rootPath = "/data/ollama/";
  openWebUiPath = "${rootPath}/open-webui";
  ollamaPath = "${rootPath}/ollama";
in
{
  systemd.services."createOllamaDirectory" = {
    script = ''
      mkdir -p ${openWebUiPath}
      mkdir -p ${ollamaPath}
    '';
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-open-webui.service" "docker-ollama.service" ];
    serviceConfig.Type = "oneshot";
  };
  virtualisation = {
    oci-containers = {
      containers = {
        open-webui = {
          hostname = "open-webui";
          image = "ghcr.io/open-webui/open-webui:main";
          autoStart = true;
          ports = [
            "127.0.0.1:8080:8080"
          ];
          volumes = [
            "${openWebUiPath}:/app/backend/data"
          ];
          environment = {
            OLLAMA_BASE_URL = "http://127.0.0.1:11434";
            ANONYMIZED_TELEMETRY = "False";
          };
          environmentFiles = [ config.age.secrets.open_webui_environment_file.path ];
          extraOptions = [
            # "--pull=newer"
            "--network=host"
            "--add-host=host.containers.internal:host-gateway"
          ];
        };

        ollama = {
          hostname = "ollama";
          image = "ollama/ollama";
          autoStart = true;
          ports = [ "11434:11434" ];
          volumes = [ "${ollamaPath}:/root/.ollama" ];
          extraOptions = [
            "--gpus=all"
            # "--pull=newer"
          ];
        };
      };
    };
  };
}
