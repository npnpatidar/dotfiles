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
      tailscale-alma
      nginx
      pocket_id_tinyauth
      adguardhome
      headscale
      mail-server
      gitea
      searx
      syncthing-alma
      karakeep
      hermes-agent
      overlays
      radicale
      webdav
      databases
      rclone-mount
      filen-sync
      oink
      llama
      n8n
      mcp
      degoog
      agent-zero
      opencode
      inputs.hermes-agent.nixosModules.default
    ];
  };
  flake.homeConfigurations."naresh@alma" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
    extraSpecialArgs = { inherit inputs; };
    modules = with config.flake.homeModules; [
      shared-modules
      llama
      n8n
      mcp
      degoog
      agent-zero
      alma-packages
      { programs.pi-coding-agent.sudoAskpass = false; }
    ];
  };
}
