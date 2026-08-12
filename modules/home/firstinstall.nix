_: {
  flake.homeModules.firstinstall = { config, ... }: {
    home.file.".scripts/firstinstall.sh" = {
      executable = true;
      text = ''
        ${config.home.homeDirectory}/.scripts/flatpak.sh
        ${config.home.homeDirectory}/.scripts/distrobox.sh
      '';
    };
  };
}
