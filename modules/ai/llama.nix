{
  flake.nixosModules.llama = { config, ... }: {

    services.nginx.virtualHosts."llama.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:11434";
      };
    };

  };

  flake.homeModules.llama =
    {
      config,
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.home.llama;
      # Upstream nixpkgs ships llama.cpp releases too old for newer model
      # architectures (e.g. LFM3); the CPU build therefore comes from a fresh
      # unstable pin.
      llamaCppMain = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.llama-cpp;
      llamaCpp = if cfg.gpu then pkgs.llama-cpp-cuda else llamaCppMain;
    in
    {
      options.home.llama = {
        gpu = lib.mkEnableOption "CUDA build of llama.cpp for NVIDIA GPUs";

        model = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = ''
            Hugging Face repo to serve via llama-server's -hf (optionally with
            a :quant tag). null starts the server without a model.
          '';
        };

        modelFile = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Exact GGUF file from the model repo to serve (passed as --hf-file).";
        };

        mcpConfigFile = lib.mkOption {
          type = with lib.types; nullOr lib.types.path;
          default = null;
          description = "MCP servers config file for llama-server (--mcp-servers-config).";
        };

        extraArgs = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Additional llama-server arguments.";
        };
      };

      config = {

        sops.secrets.llama_cpp_api_key = {
          mode = "0600";
        };

        systemd.user.services.llama-cpp = {
          Unit.Description = "LLaMA C++ server";
          Service = {
            ExecStart = lib.concatStringsSep " " (
              lib.flatten [
                "${llamaCpp}/bin/llama-server"
                "--host 0.0.0.0"
                "--api-key-file ${config.sops.secrets.llama_cpp_api_key.path}"
                "--port 11434"
                "-c 65536"
                # NOTE: --mlock was removed upstream; memory locking is now the
                # default behavior (disable with --no-mlock).
                # --cpu-moe only makes sense for the CPU build
                (lib.optionals (!cfg.gpu) [ "--cpu-moe" ])
                "--reasoning off"
                (lib.optionals (cfg.model != null) [ "-hf ${cfg.model}" ])
                (lib.optionals (cfg.modelFile != null) [ "--hf-file ${cfg.modelFile}" ])
                (lib.optionals (cfg.mcpConfigFile != null) [
                  "--mcp-servers-config ${cfg.mcpConfigFile}"
                ])
                cfg.extraArgs
              ]
            );
            Restart = "on-failure";
            KillSignal = "SIGINT";
            Environment = [
              "LLAMA_ARG_REASONING=off"
            ];
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
}
