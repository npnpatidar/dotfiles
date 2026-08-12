_: {
  flake.nixosModules.hermes-agent = { config, ... }: {
    sops.secrets = {
      "hermes-env" = {
        sopsFile = ../../secrets/alma.yaml;
      };
      groq_api_key = {
        sopsFile = ../../secrets/alma.yaml;
      };
      openrouter_api_key = {
        sopsFile = ../../secrets/alma.yaml;
      };
    };

    services.hermes-agent = {
      enable = true;
      settings.model.default = "qwen/qwen3.5-122b-a10b";
      settings.model.provider = "nvidia";
      environmentFiles = [ config.sops.secrets."hermes-env".path ];
      addToSystemPackages = true;
      extraDependencyGroups = [ "messaging" ];
    };
  };
}
