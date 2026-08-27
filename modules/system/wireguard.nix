{
  flake.nixosModules.wireguard =
    {
      config,
      lib,
      ...
    }:
    with lib;
    let
      cfg = config.systemConstants.wireguard;

      isHub = config.networking.hostName == cfg.hub.name;

      # This host's entry from the peer list. Eval fails loudly if a host imports
      # this module without being listed (only hub members may omit it).
      me = head (filter (p: p.name == config.networking.hostName) cfg.peers);
    in
    {
      # WireGuard mesh topology (replaces tailscale + headscale).
      #
      # Classic hub-and-spoke:
      #
      #   hub    alma     10.100.0.1   Oracle VPS, listens on public UDP 51820,
      #                               NATs client traffic out (full-tunnel clients)
      #   spoke  aspire7  10.100.0.2   laptop behind NAT, split tunnel
      #   client phone    10.100.0.3   gt2 (Android), full tunnel via .conf file
      #   client ipad     10.100.0.4   iPad, full tunnel via .conf file
      #
      # - All DNS flows through AdGuard Home on the hub (10.100.0.1:53).
      # - phone/ipad .conf files can be regenerated on alma; their private keys
      #   live in secrets/alma.yaml (wireguard_{phone,ipad}_private_key).
      # - Status UI: modules/services/wireguard-status.nix (https://wg.<domain>).
      config = mkMerge [
        {
          systemConstants.wireguard = {
            interface = "wg0";
            # Standard WireGuard port; must be allowed as UDP in the OCI
            # security list (TCP rules don't count).
            port = 51820;
            subnet = "10.100.0.0/24";
            endpoint = "wg.${config.systemConstants.domain_name}";

            hub = {
              name = "alma";
              ip = "10.100.0.1";
              publicKey = "3MxjYu0BsJRe4jgEJ1c0dlxDN3Hlqr9fGF9/vib39RU=";
              # Public address of the hub. Spokes pin this in /etc/hosts so the
              # endpoint resolves before the tunnel (and AdGuard DNS) exists.
              publicIp = "80.225.195.83";
            };

            peers = [
              {
                name = "aspire7";
                ip = "10.100.0.2";
                publicKey = "KJ+km6lnMM9/iB67ezasdJbibJ/BU771lCTnhGqhrlc=";
              }
              {
                name = "gt2";
                ip = "10.100.0.3";
                publicKey = "/c4pfRbP9cMxs09wJX3JtCL8w4+QFtN3D44tZ5Y9nyI=";
              }
              {
                name = "ipad";
                ip = "10.100.0.4";
                publicKey = "dTbgzh3jM/d17ATyY375Lw7LSu0IO0DYIm1pX/GEvh0=";
              }
            ];
          };

          # Each host decrypts its own private key from its host-specific sops file.
          sops.secrets.wireguard_private_key.sopsFile = ../../secrets/${config.networking.hostName}.yaml;

          networking.wireguard.interfaces.${cfg.interface} = {
            privateKeyFile = config.sops.secrets.wireguard_private_key.path;
          }
          // (
            if isHub then
              {
                listenPort = cfg.port;
                ips = [ "${cfg.hub.ip}/24" ];
                # Every spoke/client is a peer; /32 routes so the hub knows which
                # tunnel each internal IP belongs to.
                peers = map (p: {
                  inherit (p) publicKey;
                  allowedIPs = [ "${p.ip}/32" ];
                }) cfg.peers;
              }
            else
              {
                ips = [ "${me.ip}/24" ];
                peers = [
                  {
                    publicKey = cfg.hub.publicKey;
                    endpoint = "${cfg.endpoint}:${toString cfg.port}";
                    # Split tunnel: only the VPN subnet goes through the tunnel;
                    # everything else uses the local uplink. DNS still goes through
                    # AdGuard on the hub (nameservers below), which is what matters
                    # for filtering.
                    allowedIPs = [ cfg.subnet ];
                    persistentKeepalive = 25; # stay NATted behind home routers
                  }
                ];
              }
          );
        }

        # Spoke: resolve all system DNS via AdGuard on the hub. NetworkManager must
        # stop writing resolv.conf (dhcp servers would otherwise bypass AdGuard).
        # Same tradeoff as the old tailscale override_local_dns=true: no tunnel,
        # no DNS.
        (mkIf (!isHub) {
          networking = {
            nameservers = [
              cfg.hub.ip
              "1.1.1.1"
              "8.8.8.8"
            ];
            networkmanager.dns = "none";
            # Prevent NM from managing the wg interface; let the NixOS wireguard module control it.
            networkmanager.unmanaged = [ "interface-name:wg0" ];

            # Bootstrap: pin the endpoint in /etc/hosts so the tunnel can resolve
            # its own hub before any DNS is reachable (chicken-and-egg).
            hosts."${cfg.hub.publicIp}" = [ cfg.endpoint ];
          };
        })

        # Hub: accept tunnels, trust wg traffic, and NAT clients out through the
        # WAN so full-tunnel clients (gt2/ipad) reach the internet.
        (mkIf isHub {
          boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = 1;
            "net.ipv6.conf.all.forwarding" = 1;
          };

          networking = {
            firewall = {
              allowedUDPPorts = [ cfg.port ];
              trustedInterfaces = [ cfg.interface ];
            };

            nat = {
              enable = true;
              externalInterface = "enp0s6"; # Oracle virtio NIC
              internalInterfaces = [ cfg.interface ];
            };
          };
        })
      ];
    };
}
