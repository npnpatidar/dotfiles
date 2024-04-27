{ config, ... }:

{
  # virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser";
    # user = "naresh:users";
    ports = [ "8081:80" ];
    volumes = [
      "/home/naresh/"
    ];
  };


  services.nginx.virtualHosts."files.naresh.world" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:8081";
  };
}

