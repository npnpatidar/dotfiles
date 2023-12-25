{ config, pkgs, ... }:
{

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

    };
    extraConfig = {
      diff = { tool = "meld"; };
      difftool = { prompt = false; };
    };
  };

}
