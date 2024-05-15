{ pkgs, ... }:
{

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import builtins.fetchTarball
      {
        url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
        sha256 = "sha256:0plki2yk02zcvyw7vynqhag6g1kl5qcicj8dvzfjx5p3p82yilkk";
      }
      {
        inherit pkgs;
      };
  };

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
