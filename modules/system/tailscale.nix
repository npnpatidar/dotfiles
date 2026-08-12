{ lib, ... }: with lib;
{
  flake.nixosModules.tailscale =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      sops.secrets.tailscale_key = { };

      environment.systemPackages = [ pkgs.tailscale ];

      services.tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets.tailscale_key.path;
        extraUpFlags = [
          "--login-server=https://headscale.${config.systemConstants.domain_name}"
          "--accept-dns=true"
          "--hostname=${config.networking.hostName}"
        ];
      };

      systemd.services.tailscaled-autoconnect.wantedBy = lib.mkForce [ "multi-user.target" ];

      networking.firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };
    };
}
