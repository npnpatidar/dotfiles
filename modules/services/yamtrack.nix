_: {
  # Yamtrack — self-hosted media tracker (movies / TV / anime / manga / games / books).
  # Served at https://yamtrack.<domain> via nginx, backed by Podman Quadlet
  # containers (yamtrack + yamtrack-redis) managed as rootless user services by home-manager.
  #
  # Exposed as a NixOS module (reverse proxy + oink DNS) and a home module
  # (Quadlet containers + sops secret), mirroring n8n / degoog.
  flake.nixosModules.yamtrack = { config, ... }: {
    services.oink.domains = [
      {
        domain = "${config.systemConstants.domain_name}";
        subdomain = "yamtrack";
      }
    ];

    services.nginx.virtualHosts."yamtrack.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000";
        proxyWebsockets = true;
      };
    };
  };

  # Rootless Quadlet containers. Join the shared bridge network ("services")
  # so the yamtrack app can resolve yamtrack-redis by name via aardvark-dns.
  flake.homeModules.yamtrack = { config, inputs, ... }: {
    imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

    # Django SECRET key, injected into the container via an environment file
    # (podman --env-file). Managed by the sops home-manager module so the file
    # lands under the user's own secrets dir (rootless container can read it).
    sops.secrets.yamtrack_environment_file = {
      sopsFile = ../../secrets/alma.yaml;
      mode = "0600";
    };

    virtualisation.quadlet.containers.yamtrack = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";
        After = [ "container-yamtrack-redis.service" ];
        Requires = [ "container-yamtrack-redis.service" ];
      };
      containerConfig = {
        image = "ghcr.io/fuzzygrim/yamtrack";
        networks = [ "services" ];
        publishPorts = [ "127.0.0.1:8000:8000" ];
        # Named volume (rootless podman-managed): yamtrack's entrypoint runs
        # groupmod/usermod/chown and therefore needs to be root inside. A
        # bind mount to the /mnt/filen fuse share would need keep-id (which
        # runs non-root and breaks the entrypoint), so keep the DB in a named
        # volume instead — same pattern as yamtrack-redis.
        volumes = [ "yamtrack-data:/yamtrack/db" ];
        environmentFiles = [ config.sops.secrets.yamtrack_environment_file.path ];
        environments = {
          TZ = "Asia/Kolkata";
          REDIS_URL = "redis://yamtrack-redis:6379";
          URLS = "https://yamtrack.${config.systemConstants.domain_name}";
        };
      };
    };

    virtualisation.quadlet.containers.yamtrack-redis = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";
      };
      containerConfig = {
        image = "docker.io/library/redis:8-alpine";
        networks = [ "services" ];
        # Named volume (rootless podman-managed) avoids fuse-mount permission
        # issues with the redis UID remap; data is ephemeral cache/broker anyway.
        volumes = [ "yamtrack-redis:/data" ];
        exec = [
          "redis-server"
          "--appendonly"
          "yes"
        ];
      };
    };
  };
}
