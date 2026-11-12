_: {
  flake.homeModules.core = { config, ... }: {
    nixpkgs.config = {
      allowUnfree = true;

      # onlyoffice-desktopeditors still depends on gtk2, which nixpkgs now flags
      # as broken (gtk2 removal planned for 27.05). Warn instead of failing eval.
      problems.handlers."gtk+".broken = "warn";
    };

    home = {
      username = config.systemConstants.default_user;
      homeDirectory = config.systemConstants.home_directory;
      stateVersion = "26.05";
    };

    home.sessionVariables.EDITOR = "nvim";

    programs.home-manager.enable = true;
    systemd.user.startServices = "sd-switch";
  };
}
