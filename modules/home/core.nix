_: {
  flake.homeModules.core = { config, ... }: {
    nixpkgs.config.allowUnfree = true;

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
