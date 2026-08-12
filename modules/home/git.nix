_: {
  flake.homeModules.git = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      hub
      meld
      git-graph
      lazygit
      gh
      onefetch
      git-lfs
    ];
    programs = {
      difftastic = {
        enable = true;
        options = {
          background = "dark";
          color = "always";
          display = "side-by-side-show-both";
        };
      };
      git = {
        enable = true;
        lfs.enable = true;
        settings = {
          user.name = "npnpatidar";
          user.email = config.systemConstants.git_email;
          alias = {
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
          diff.tool = "meld";
          difftool.prompt = false;
          init.defaultBranch = "main";
        };
      };
    };

    sops.secrets.gh_token = {
      mode = "0600";
    };

    sops.templates.gh-hosts = {
      content = ''
        github.com:
            oauth_token: ${config.sops.placeholder.gh_token}
            user: npnpatidar
            git_protocol: ssh
      '';
      path = "${config.home.homeDirectory}/.config/gh/hosts.yml";
      mode = "0600";
    };
  };
}
