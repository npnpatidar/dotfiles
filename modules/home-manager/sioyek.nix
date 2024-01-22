{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.sioyek;
in
{
  options.modules.home-manager.sioyek = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.sioyek
    ];
    # home.file.".config/sioyek/settings.json" = {
    #   # source = "../../../.secrets/Master PDF Editor 5.conf";
    #   source = ../../.secrets + "/sioyek.json";
    #   # executable = true;
    # };
  };
}
