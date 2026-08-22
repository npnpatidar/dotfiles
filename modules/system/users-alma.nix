_: {
  flake.nixosModules.users-alma = { config, ... }: {
    users = {
      users."${config.systemConstants.default_user}".extraGroups = [
        "podman"
        "usbmux"
        "nginx"
        "syncthing"
        "fuse"
      ];

    };
  };
}
