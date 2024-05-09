{ config, pkgs, ... }: {

  # Syncthign Settings
  services = {
    syncthing = {
      enable = true;
      user = "naresh";
      dataDir = "/home/naresh/Data/Sync_M_L/";
      configDir = "/home/naresh/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings.gui = {
        user = "naresh";
        password = "naresh";
      };
      settings.devices = {
        "RMX3312" = {
          id = "TYHX2SD-7KN5PCE-DMUV7F6-T5I22IU-5XJNC2A-JUAWJCK-M74C276-U6PNGAA";
          name = "RMX3312";
          autoAcceptFolders = true;
        };

        "Ipad" = {
          id = "EYUCT6O-SQMOKM2-UWA5QAN-OVFGS3G-NNKX5RC-IBL5FLF-LD3YR55-LLMJOA4";
          name = "Ipad";
          autoAcceptFolders = true;
        };
        "alma" = {
          id = "JFSJDCN-3S2VMRZ-DQLU4NX-AQHE6ZD-D4PYCUA-7H3NBS3-GX7KFL3-4I53AAL";
          name = "alma";
          autoAcceptFolders = true;
          addresses = [
            "tcp://alma.tail4db3da.ts.net:22000"
          ];
        };
      };

      settings.folders = {
        "Camera" = {
          id = "knuao-1ygcm";
          label = "Camera";
          path = "/home/naresh/Camera";
          devices = [ "RMX3312" ];
        };
        "Sync_M_L" = {
          id = "tpz2c-x9q93";
          label = "Sync_M_L";
          path = "/home/naresh/Data/Sync_M_L";
          devices = [ "RMX3312" ];
        };

        "Sync_M_L_I_O" = {
          id = "";
          label = "Sync_M_L_I_O";
          path = "/home/naresh/Data/Sync_M_L_I_O";
          devices = [ "RMX3312" "Ipad" "alma" ];
        };
        "Sync_M_L_I_C" = {
          id = "7snbs-p6fiq";
          label = "Sync_M_L_I_C";
          path = "/home/naresh/Data/Sync_M_L_I_C";
          devices = [ "RMX3312" "Ipad" ];
        };
        "Sync_M_L_I" = {
          id = "pwm3j-ulcds";
          label = "Sync_M_L_I";
          path = "/home/naresh/Data/Sync_M_L_I";
          devices = [ "RMX3312" "Ipad" ];
        };
      };
    };
  };



}
