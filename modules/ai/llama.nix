_: {
  flake.nixosModules.llama = { config, ... }: {

    services.nginx.virtualHosts."llama.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:11434";
      };
    };

    sops.secrets.llama_cpp_api_key = {
      # shared.yaml is decryptable by all hosts (see .sops.yaml key groups)
      sopsFile = ../../secrets/shared.yaml;
      mode = "0600";
      owner = "${config.systemConstants.default_user}";
    };
  };

  flake.homeModules.llama =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.home.llama.gpu = lib.mkEnableOption "CUDA build of llama.cpp for NVIDIA GPUs";

      config = {

        systemd.user.services.llama-cpp = {
          Unit.Description = "LLaMA C++ server";
          Service = {
            ExecStart = lib.concatStringsSep " " (
              lib.flatten [
                "${(if config.home.llama.gpu then pkgs.llama-cpp-cuda else pkgs.llama-cpp)}/bin/llama-server"
                "--host 0.0.0.0"
                "--api-key-file /run/secrets/llama_cpp_api_key"
                "--port 11434"
                "-c 65536"
                "--mlock"
                # --cpu-moe only makes sense for the CPU build
                (lib.optionals (!config.home.llama.gpu) [ "--cpu-moe" ])
                "--reasoning off"
                "--mcp-servers-config ${config.home.homeDirectory}/.config/mcp/mcp.json"
              ]
            );
            Restart = "on-failure";
            KillSignal = "SIGINT";
            Environment = [
              "LLAMA_ARG_REASONING=off"
              ''"LLAMA_ARG_CHAT_TEMPLATE_KWARGS={\"enable_thinking\":false}"''
            ];
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
}
