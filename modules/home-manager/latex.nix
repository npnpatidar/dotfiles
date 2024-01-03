{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.latex;
in
{
  options.modules.home-manager.latex = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[
      texliveMedium
      gnome-latex
    ];

  };
}
