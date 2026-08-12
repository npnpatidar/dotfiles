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

      users.root.openssh.authorizedKeys.keys = [
        config.systemConstants.user_ssh_key
      ];

    };
  };
}
