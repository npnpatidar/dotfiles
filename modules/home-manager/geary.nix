{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.geary;
in
{
  options.modules.home-manager.geary = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.gnome.geary
    ];
    home.file.".config/geary/user-style.css".text = ''
     
    :root *:not(a) {
        color: #eeeeec !important;
        background-color: #3B4252!important;

    }

     '';
  };
}
