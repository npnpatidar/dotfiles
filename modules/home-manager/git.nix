{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.git;
in
{
  options.modules.home-manager.git = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[
      hub
      meld # for git difftool
      git-graph
      lazygit
      gh
    ];
    programs.git = {
      enable = true;
      userName = "npnpatidar";
      userEmail = "7de6dkm1@duck.com";
      lfs.enable = true;
      difftastic = {
        enable = true;
        background = "dark";
        color = "always";
        display = "side-by-side-show-both";
      };
      aliases = {
        ci = "commit";
        co = "checkout";
        s = "status";
        aa = "add .";
        p = "push";
        d = "diff";
        ds = "diff --staged";
        dt = "difftool";
        l = "log --graph --abbrev-commit --decorate --date=relative --all";
      };
      extraConfig = {
        diff = { tool = "meld"; };
        difftool = { prompt = false; };
        init.defaultBranch = "main";
      };
    };
  };
}
