_: {
  flake.homeModules.newsboat = { config, pkgs, ... }: {
    home.packages = with pkgs; [ newsboat ];
    home.file.".newsboat/config".source =
      config.lib.file.mkOutOfStoreSymlink ../../.secrets + "/newsboat_config";
  };
}
