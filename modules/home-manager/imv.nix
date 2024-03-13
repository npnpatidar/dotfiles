{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.imv;
in
{
  options.modules.home-manager.imv = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    programs.imv = {
      enable = true;

      settings.binds = {
        "<Escape>" = "quit";
        "<minus>" = "zoom -1";
        "<space>" = "next";
        "<equal>" = "zoom 1";
        "<m>" = "rotate by 90";
        "<n>" = "rotate by -90";
        "<u>" = "rotate by 1";
        "<y>" = "rotate by -1";
      };
    };
  };
}
