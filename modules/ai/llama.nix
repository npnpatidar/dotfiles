_:
let
  llamaCppOverlay = final: prev: {
    llama-cpp =
      let
        origPreConfigure = prev.llama-cpp.preConfigure or "";
      in
      prev.llama-cpp.overrideAttrs (finalAttrs: rec {
        # Tagged release with MCP support.
        version = "10253";
        src = prev.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          rev = "94bc47f2807805ffdc1c5fbe5dce5cd2afdf3a97";
          hash = "sha256-U9ubELkeW08EHnVgQFtVXqGbI9fPpTjuoNmKI4i5qf4=";
          leaveDotGit = true;
          postFetch = ''
            git -C "$out" rev-parse --short HEAD > $out/COMMIT
            find "$out" -name .git -print0 | xargs -0 rm -rf
          '';
        };
        buildInputs = (finalAttrs.buildInputs or [ ]) ++ [ prev.curl ];
        npmRoot = "tools/ui";
        npmDepsHash = "sha256-B7uEynAG70a3xauBKc20RuFa9cnWaWzVBCh+LPLBnIM=";
        preConfigure = builtins.replaceStrings [ "tools/server/webui" ] [ "tools/ui" ] origPreConfigure;
      });
    llama-cpp-cuda = final.llama-cpp.override { cudaSupport = true; };
  };
in
{
  perSystem = { pkgs, system, ... }: {
    # CPU build, exposed as .#llama-cpp for local use.
    packages.llama-cpp = (pkgs.extend llamaCppOverlay).llama-cpp;

    # CUDA build matching what the aspire7 home module produces
    # (home.llama.gpu = true + nixpkgs.config cudaVersion/cudaCapabilities),
    # so the store path is identical to the host's home-manager build
    # and CI can pre-build/cache it for the machine.
    # Uses pkgs.path (the same nixpkgs source the flake is pinned to).
    packages.llama-cpp-cuda =
      let
        pkgsCuda = import pkgs.path {
          inherit system;
          config = {
            allowUnfree = true;
            cudaVersion = "12.4";
            cudaCapabilities = [ "7.5" ];
          };
        };
      in
      (pkgsCuda.extend llamaCppOverlay).llama-cpp-cuda;
  };

  flake.nixosModules.llama = { config, ... }: {
    nixpkgs.overlays = [ llamaCppOverlay ];

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
        nixpkgs.overlays = [ llamaCppOverlay ];

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
