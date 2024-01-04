{ config, lib, pkgs, ... }:
{

  environment.packages = with pkgs; [
    lunarvim
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
        home = {
          username = "naresh";
          homeDirectory = "/data/data/com.termux.nix/files/home";
          stateVersion = "23.05";
        };
        home.packages = with pkgs; [
          lunarvim
          eza
          screenfetch
        ];
        # insert home-manager config
        user.shell = "${pkgs.zsh}/bin/zsh";
        programs.home-manager.enable = true;

        naresh.shell = {
          enable = true;
          username = "rmx3312";
          hostname = "rmx3312";
          atuin = true;
          direnv = true;
          zoxide = true;
        };
      };
  };
}


