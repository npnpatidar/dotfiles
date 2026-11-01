_: {
  flake.homeModules.euro-office = { pkgs, ... }: {
    # Euro-Office (OnlyOffice fork) desktop editors
    home.packages = [ pkgs.euro-office-desktopeditors ];
  };
}
