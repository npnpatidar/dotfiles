_: {
  flake.nixosModules.oink = { config, ... }: {
    sops.secrets.oink_api_key = {
      sopsFile = ../../secrets/alma.yaml;
    };
    sops.secrets.oink_secret_api_key = {
      sopsFile = ../../secrets/alma.yaml;
    };

    services.oink = {
      enable = true;
      apiKeyFile = config.sops.secrets."oink_api_key".path;
      secretApiKeyFile = config.sops.secrets."oink_secret_api_key".path;
      domains = [ ];
    };
  };
}
