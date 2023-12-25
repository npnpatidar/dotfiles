{ pkgs, ... }:
{


  # Update nixos
  system.autoUpgrade = {
    #		enable = true;
    allowReboot = false;
    channel = "https://channels.nixos.org/nixos-unstable";
  };

  system.stateVersion = "23.05"; # Did you read the comment?


  nix = {

    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings.auto-optimise-store = true;
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };


}
