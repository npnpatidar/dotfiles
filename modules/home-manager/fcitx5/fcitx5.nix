{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.fcitx5;
in
{
  options.modules.home-manager.fcitx5 = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    home.file.".config/fcitx5/profile".source = config.lib.file.mkOutOfStoreSymlink ./profile;
    home.file.".config/fcitx5/config".source = config.lib.file.mkOutOfStoreSymlink ./config;

  };
}
