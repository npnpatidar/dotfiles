_: {
  # Scrob — self-hosted media tracking app (Jellyfin / Plex / Emby -> Trakt /
  # Letterboxd-style personal lists).
  # Served at https://scrob.<domain> via nginx, backed by Podman Quadlet
  # containers (scrob + scrob-db Postgres) managed as rootless user services
  # by home-manager.
  #
  # Exposed as a NixOS module (reverse proxy + oink DNS) and a home module
  # (Quadlet containers + sops secret), mirroring yamtrack / n8n / degoog.
  flake.nixosModules.scrob = { config, ... }: {
    services.oink.domains = [
      {
        domain = "${config.systemConstants.domain_name}";
        subdomain = "scrob";
      }
    ];

    services.nginx.virtualHosts."scrob.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7330";
        proxyWebsockets = true;
      };
    };
  };

  # Rootless Quadlet containers. Join the shared bridge network ("services")
  # so the scrob app can resolve scrob-db by name via aardvark-dns.
  flake.homeModules.scrob = { config, inputs, ... }: {
    imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

    # SECRET_KEY + Postgres credentials, injected into the containers via an
    # environment file (podman --env-file). Managed by the sops home-manager
    # module so the file lands under the user's own secrets dir (rootless
    # containers can read it). Both containers read the same file: scrob-db
    # picks up POSTGRES_USER/PASSWORD/DB, scrob picks up SECRET_KEY and
    # DATABASE_URL.
    sops.secrets.scrob_environment_file = {
      sopsFile = ../../secrets/alma.yaml;
      mode = "0600";
    };

    virtualisation.quadlet.containers.scrob-db = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";
      };
      containerConfig = {
        image = "docker.io/library/postgres:16-alpine";
        networks = [ "services" ];
        # Named volume (rootless podman-managed) for persistent Postgres data.
        volumes = [ "scrob-db:/var/lib/postgresql/data" ];
        environmentFiles = [ config.sops.secrets.scrob_environment_file.path ];
      };
    };

    virtualisation.quadlet.containers.scrob = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";
        After = [ "container-scrob-db.service" ];
        Requires = [ "container-scrob-db.service" ];
      };
      containerConfig = {
        image = "docker.io/bellamy/scrob:latest";
        networks = [ "services" ];
        publishPorts = [ "127.0.0.1:7330:7330" ];
        # Named volume for app data (uploads / config) across container updates.
        volumes = [ "scrob-data:/app/backend/data" ];
        environmentFiles = [ config.sops.secrets.scrob_environment_file.path ];
        environments = {
          TZ = "Asia/Kolkata";
          SERVER_URL = "https://scrob.${config.systemConstants.domain_name}";
        };
      };
    };
  };
}
