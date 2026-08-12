{ lib, ... }: with lib;
{
  flake.nixosModules.containerization = { config, ... }: {
    virtualisation = {
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
        autoPrune.enable = true;
      };
      quadlet.enable = true;
    };

    users.groups.podman.members = [ "${config.systemConstants.default_user}" ];
  };
}
