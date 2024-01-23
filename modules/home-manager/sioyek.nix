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
    home.file.".config/sioyek/prefs_user.config".text =''
       default_dark_mode 1
    '';
    home.file.".config/sioyek/keys_user.config".text =''
       toggle_dark_mode x
    '';
    xdg.desktopEntries = {
      "sioyek" = {
        exec = "sioyek --new-window";
        name = "sioyek";
        settings.NoDisplay = "false";
      };
  };
  };
}
