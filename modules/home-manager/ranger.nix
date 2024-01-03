{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.ranger;
in
{
  options.modules.home-manager.ranger = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lynx
      mupdf
      ranger

    ];
    home.file."ranger_devicons" = {
      source = builtins.fetchGit {
        url = "https://github.com/alexanderjeurissen/ranger_devicons";
        rev = "de64ab26fb581c00a803381d522c6b3e48b79415";
      };
      target = ".config/ranger/plugins/ranger_devicons";
    };


    home.file."ranger_rc_conf" = {
      text = ''
        default_linemode devicons
      '';
      target = ".config/ranger/rc.conf";
    };
  };
}



