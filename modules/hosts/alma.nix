{ config, inputs, ... }: {
  flake.nixosConfigurations.alma = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = with config.flake.nixosModules; [
      shared-modules
      { networking.hostName = "alma"; }
      alma-hardware
      users-alma
      networking-alma
      openssh-alma
      wireguard-status
      nginx
      pocket_id_tinyauth
      adguardhome
      mail-server
      gitea
      searx
      syncthing-alma
      karakeep
      ntfy
      overlays
      radicale
      webdav
      rclone-mount
      filen-sync
      oink
      degoog
      opencode
    ];
  };
  flake.homeConfigurations."naresh@alma" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
    extraSpecialArgs = { inherit inputs; };
    modules = with config.flake.homeModules; [
      shared-modules
      degoog
      alma-packages
      { programs.pi-coding-agent.sudoAskpass = false; }
    ];
  };
}
