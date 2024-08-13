{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.neovim;
in
{
  options.modules.home-manager.neovim = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # package = pkgs.unstable.neovim-unwrapped;
  };

  xdg.configFile.nvim = {
    source = builtins.fetchGit {
      url = "https://github.com/LazyVim/starter.git";
  rev = "79b3f27f5cea8fe6bbb95ba04f93dffa545c5197";
      

    };
    recursive = true;
  };

    };
}
