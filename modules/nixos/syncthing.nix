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
      settings.devices = {
        "RMX3312" = {
          id = "TYHX2SD-7KN5PCE-DMUV7F6-T5I22IU-5XJNC2A-JUAWJCK-M74C276-U6PNGAA";
          name = "RMX3312";
          autoAcceptFolders = true;
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
        "Sync_M_L_C" = {
          id = "7snbs-p6fiq";
          label = "Sync_M_L_C";
          path = "/home/naresh/Data/Sync_M_L_C";
          devices = [ "RMX3312" ];
        };
      };
    };
  };



}
