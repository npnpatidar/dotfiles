{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.nvim;
in
{
  options.modules.home-manager.nvim = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    home.file.".config/nvim".source = pkgs.fetchFromGitHub {
      owner = "LazyVim";
      repo = "starter";
      rev = "master";
      hash = "sha256-gE2tRpglA0SxxjGN+uKwkwdR5YurvjVGf8SRKkW0E1U=";
    };


    programs.nixvim = {

      enable = true;


    };



  };
}
