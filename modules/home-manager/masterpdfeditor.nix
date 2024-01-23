{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.masterpdfeditor;
in
{
  options.modules.home-manager.masterpdfeditor = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.masterpdfeditor
    ];
    home.file.".config/Code Industry/Master PDF Editor 5.conf".source = config.lib.file.mkOutOfStoreSymlink ../../.secrets + "/Master PDF Editor 5.conf";
  };
}
