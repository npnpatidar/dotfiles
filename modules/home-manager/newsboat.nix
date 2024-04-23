{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.newsboat;
in
{
  options.modules.home-manager.newsboat = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      newsboat
    ];
    home.file.".newsboat/config".source = config.lib.file.mkOutOfStoreSymlink ../../.secrets + "/newsboat_config";
  };
}
