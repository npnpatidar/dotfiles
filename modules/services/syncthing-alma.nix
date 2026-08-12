_: {
  flake.nixosModules.syncthing-alma = { config, ... }: {
    sops.secrets = {
      alma_syncthing_cert = {
        sopsFile = ../../secrets/alma.yaml;
      };
      alma_syncthing_key = {
        sopsFile = ../../secrets/alma.yaml;
      };
    };

    services = {
      syncthing = {
        openDefaultPorts = true;
        overrideDevices = false;
        cert = config.sops.secrets.alma_syncthing_cert.path;
        key = config.sops.secrets.alma_syncthing_key.path;
        settings.devices = {
          "aspire7" = {
            id = "AMLTZD5-IXO6XQ2-LVECZQ4-TZVK6XD-6OXEX6O-MTKZ2AY-RFS2SJJ-76HYNAU";
            name = "aspire7";
            autoAcceptFolders = false;
            addresses = [
              "dynamic"
              "tcp://aspire7.n:22000"
            ];
          };
        };
        settings.folders = {
          "Sync_M_L_I_O" = {
            id = "y3xfw-sbf3u";
            label = "Sync_M_L_I_O";
            path = "${config.systemConstants.data_directory}/Sync_M_L_I_O";
            devices = [
              "android"
              "ipad"
              "aspire7"
            ];
          };
          "Sync_L_O" = {
            id = "xcdob-rhava";
            label = "Sync_L_O";
            path = "${config.systemConstants.data_directory}/Sync_L_O";
            devices = [ "aspire7" ];
          };
          "Sync_M_L_O" = {
            id = "loz1l-5xeky";
            label = "Sync_M_L_O";
            path = "${config.systemConstants.data_directory}/Sync_M_L_O";
            devices = [
              "aspire7"
              "android"
            ];
          };
        };
      };

      nginx = {
        virtualHosts."syncthing.${config.systemConstants.domain_name}" = {
          forceSSL = true;
          enableTinyauth = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://0.0.0.0:8384";
          };
        };
      };

      oink.domains = [
        {
          domain = "${config.systemConstants.domain_name}";
          subdomain = "syncthing";
        }
      ];
    };
  };
}
