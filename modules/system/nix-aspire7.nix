_: {
  flake.nixosModules.nix-aspire7 = {
    nix.settings.substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
      "https://npnpatidar.cachix.org"
    ];
    nix.settings."trusted-public-keys" = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
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
