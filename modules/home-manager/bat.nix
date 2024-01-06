{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.bat;
in
{
  options.modules.home-manager.bat = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    programs.zsh.shellAliases = {
      "-g -- --help" = "--help 2>&1 | bat --language=help --style=plain";
      "-g -- -h" = "-h 2>&1 | bat --language=help --style=plain";
      cat = "bat";
      rg = "batgrep";
      ripgrep = "batgrep";
      man = "batman";
    };

    programs.bat = {
      enable = true;
      config = {
        map-syntax = [
        ];
        pager = "less -FR";
        theme = "base16";
      };
      extraPackages = with pkgs.bat-extras;[ batdiff batgrep batman batwatch ];
    };
  };
}











