{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.ollama;
in
{
  options.modules.home-manager.ollama = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    home.packages = [
      # pkgs.ollama
      (pkgs.ollama.override { acceleration = "cuda"; })
      pkgs.oterm
      # pkgs.python312Packages.litellm
    ];

  };
}
