_: {
  flake.nixosModules.nix-aspire7 = {
    nix.settings.substituters = [
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://npnpatidar.cachix.org"
    ];
    nix.settings."trusted-public-keys" = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "npnpatidar.cachix.org-1:slDM+6A9sX+ETHd9PttkqYHimtAjJ065Lj7fN/TBmrQ="
    ];

    services.journald.settings.Journal = {
      SystemMaxUse = "500M";
      MaxRetentionSec = "2week";
    };

    system.autoUpgrade = {
      allowReboot = false;
      channel = "https://channels.nixos.org/nixos-unstable";
    };
  };
}
