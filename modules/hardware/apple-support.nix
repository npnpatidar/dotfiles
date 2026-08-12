_: {
  flake.nixosModules.apple-support = { pkgs, ... }: {
    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
  };
}
