{ config, ... }:

{
  # networking.firewall.allowedTCPPorts = [
  # Pi-Hole
  # 8053
  #         # DNS
  #             53
  #               ];
  #                 networking.firewall.allowedUDPPorts = [
  #                     # DNS
  #                         53
  #                           ];
  #
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole";
    volumes = [
      "pihole:/etc/pihole"
      "dnsmasq:/etc/dnsmasq.d"
    ];
    extraOptions = [
      "--network=host"
    ];
    environment = {
      WEB_PORT = "8053";
      TZ = "Asia/Kolkata";
      # WEBPASSWORD_FILE = config.age.secrets.standard.path;
      WEBPASSWORD = "naresh";
    };
  };
}
