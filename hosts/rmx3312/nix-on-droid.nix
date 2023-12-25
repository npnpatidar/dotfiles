{ config, lib, pkgs, ... }:
{

  environment.packages = with pkgs; [
    neovim
    git
    btop
    bat
    nano
    neofetch

  ];
  environment.etcBackupExtension = ".bak";
  system.stateVersion = "23.05";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  # Configure home-manager
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    config =
      { config, lib, pkgs, ... }:
      {
        # Read the changelog before changing this value
        home.stateVersion = "23.05";

        # insert home-manager config
      };
  };
}


