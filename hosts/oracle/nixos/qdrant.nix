{ config, pkgs, ... }: {

  services.nginx = {


    virtualHosts."qdrant.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:6333";
      };
    };

  };


  services.qdrant = {
    enable = true;
    settings = {
      hsnw_index = {
        on_disk = true;
      };

      service = {
        grpc_port = 6334;
        host = "127.0.0.1";
        http_port = 6333;
      };
      storage = {
        snapshots_path = "/var/lib/qdrant/snapshots";
        storage_path = "/var/lib/qdrant/storage";
      };
      telemetry_disabled = true;
    };
  };

} 
