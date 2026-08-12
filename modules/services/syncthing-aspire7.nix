_: {
  flake.nixosModules.syncthing-aspire7 = { config, ... }: {
    sops.secrets = {
      aspire7_syncthing_cert = {
        sopsFile = ../../secrets/aspire7.yaml;
      };
      aspire7_syncthing_key = {
        sopsFile = ../../secrets/aspire7.yaml;
      };
    };

    services.syncthing = {
      openDefaultPorts = false;
      overrideDevices = true;
      cert = config.sops.secrets.aspire7_syncthing_cert.path;
      key = config.sops.secrets.aspire7_syncthing_key.path;
      settings.devices = {
        "alma" = {
          id = "KW4HXPN-HB2DJNX-IQT5YFM-UBDJUWD-LJNS5TX-3Z23EIG-7NJZ5KF-2N6DFQZ";
          name = "alma";
          autoAcceptFolders = false;
          addresses = [
            "dynamic"
            "tcp://alma.n:22000"
          ];
        };
      };
      settings.folders = {
        "Camera" = {
          id = "knuao-1ygcm";
          label = "Camera";
          path = "${config.systemConstants.data_directory}/Camera";
          devices = [ "android" ];
        };
        "Sync_M_L" = {
          id = "tpz2c-x9q93";
          label = "Sync_M_L";
          path = "${config.systemConstants.data_directory}/Sync_M_L";
          devices = [ "android" ];
        };
        "Sync_M_L_I_O" = {
          id = "y3xfw-sbf3u";
          label = "Sync_M_L_I_O";
          path = "${config.systemConstants.data_directory}/Sync_M_L_I_O";
          devices = [
            "android"
            "ipad"
            "alma"
          ];
        };
        "Sync_M_L_I_C" = {
          id = "7snbs-p6fiq";
          label = "Sync_M_L_I_C";
          path = "${config.systemConstants.data_directory}/Sync_M_L_I_C";
          devices = [
            "android"
            "ipad"
          ];
          ignorePatterns = [ "Notes/**/*.obsidian/" ];
        };
        "Sync_M_L_I" = {
          id = "pwm3j-ulcds";
          label = "Sync_M_L_I";
          path = "${config.systemConstants.data_directory}/Sync_M_L_I";
          devices = [
            "android"
            "ipad"
          ];
        };
        "Sync_L_O" = {
          id = "xcdob-rhava";
          label = "Sync_L_O";
          path = "${config.systemConstants.data_directory}/Sync_L_O";
          devices = [ "alma" ];
        };
        "Sync_M_L_O" = {
          id = "loz1l-5xeky";
          label = "Sync_M_L_O";
          path = "${config.systemConstants.data_directory}/Sync_M_L_O";
          devices = [
            "alma"
            "android"
          ];
        };
      };
    };
  };
}
