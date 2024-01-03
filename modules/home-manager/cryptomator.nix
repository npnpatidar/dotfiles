{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.cryptomator;
in
{
  options.modules.home-manager.cryptomator = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.cryptomator
    ];
    home.file.".config/Cryptomator/settings.json" = {
      # source = "../../../.secrets/Master PDF Editor 5.conf";
      source = ../../.secrets + "/Cryptomator.json";
      # executable = true;
    };
  };
}
