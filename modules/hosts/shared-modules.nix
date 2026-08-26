{ config, inputs, ... }:

{
  flake.nixosModules.shared-modules = { ... }: {
    imports = with config.flake.nixosModules; [
      syncthing
      containerization
      wireguard
      inputs.quadlet-nix.nixosModules.quadlet
      nix
      users
      networking
      openssh
      time-locale
      inputs.sops-nix.nixosModules.sops
      config.flake.modules.generic.systemConstants
    ];

    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age.generateKey = true;
      defaultSopsFile = ../../secrets/shared.yaml;
    };
  };

  flake.homeModules.shared-modules = { ... }: {
    imports = with config.flake.homeModules; [
      herdr
      yazi
      bat
      core
      shell
      git
      neovim
      opencode
      pi-coding-agent
      freebuff
      common-packages
      omniroute
      inputs.sops-nix.homeManagerModules.sops
      config.flake.modules.generic.systemConstants
    ];

    sops = {
      age.sshKeyPaths = [ "${builtins.getEnv "HOME"}/.ssh/id_ed25519" ];
      defaultSopsFile = ../../secrets/shared.yaml;
    };
  };
}
