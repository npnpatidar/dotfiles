{ ... }: {
  services = {
    syncthing = {
      enable = true;
      user = "naresh";
      openDefaultPorts = true;
      dataDir = "/home/naresh/Data/";
      configDir = "/home/naresh/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      guiAddress = "alma.tail4db3da.ts.net:8384";
      # extraFlags = [
      #   "-gui-address=alma.tail4db3da.ts.net:8384"
      # ];
      # relay.enable = true;
      settings.gui = {
        user = "naresh";
        password = "naresh";
      };
      settings.devices = {

        "RMX3312" = {
          id = "TYHX2SD-7KN5PCE-DMUV7F6-T5I22IU-5XJNC2A-JUAWJCK-M74C276-U6PNGAA";
          name = "RMX3312";
          autoAcceptFolders = true;
          addresses = [
            "tcp://realme.tail4db3da.ts.net:22000"
          ];
        };
        #
        "Ipad" = {
          id = "EYUCT6O-SQMOKM2-UWA5QAN-OVFGS3G-NNKX5RC-IBL5FLF-LD3YR55-LLMJOA4";
          name = "Ipad";
          autoAcceptFolders = true;
          addresses = [
            "tcp://ipad.tail4db3da.ts.net:22000"
          ];
        };
        "nixos" = {
          id = "OMKURTY-PGTTG6P-ZUJDTQD-FV7Z6YM-FUPIFGZ-FEDVDA2-N6C7IFR-OXAFHAM";
          name = "nixos";
          autoAcceptFolders = true;
          addresses = [
            "tcp://nixos.tail4db3da.ts.net:22000"
          ];
        };
      };

      settings.folders = {
        # "Camera" = {
        # id = "knuao-1ygcm";
        #   label = "Camera";
        #   path = "/home/naresh/Camera";
        #   devices = [ "RMX3312" ];
        # };
        # "Sync_M_L" = {
        #   id = "tpz2c-x9q93";
        #   label = "Sync_M_L";
        #   path = "/home/naresh/Data/Sync_M_L";
        #   devices = [ "RMX3312" ];
        # };
        # "Sync_M_L_I_C" = {
        #   id = "7snbs-p6fiq";
        #   label = "Sync_M_L_I_C";
        #   path = "/home/naresh/Data/Sync_M_L_I_C";
        #   devices = [ "RMX3312" "Ipad" ];
        # };
        # "Sync_M_L_I" = {
        #   id = "pwm3j-ulcds";
        #   label = "Sync_M_L_I";
        #   path = "/home/naresh/Data/Sync_M_L_I";
        #   devices = [ "RMX3312" "Ipad" ];
        # };
        "Sync_M_L_I_O" = {
          id = "y3xfw-sbf3u";
          label = "Sync_M_L_I_O";
          path = "/home/naresh/Data/Sync_M_L_I_O";
          devices = [ "RMX3312" "Ipad" "nixos" ];
        };
      };
    };
  };



}
