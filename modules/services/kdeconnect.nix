_: {
  flake.homeModules.kdeconnect = _: {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
