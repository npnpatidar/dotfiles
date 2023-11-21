{ config, pkgs, ... }: {

  # Syncthign Settings
  services = {
    syncthing = {
      enable = true;
      user = "naresh";
      dataDir = "/home/naresh/Data/Sync_M_L/";
      configDir = "/home/naresh/.config/syncthing";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings.devices = {
        "RMX3312" = { id = "TYHX2SD-7KN5PCE-DMUV7F6-T5I22IU-5XJNC2A-JUAWJCK-M74C276-U6PNGAA"; };
        #  "device2" = { id = "DEVICE-ID-GOES-HERE"; };
      };
      settings.folders = {
        "knuao-1ygcm" = {
          label = "Camera";
          # Name of folder in Syncthing, also the folder ID
          path = "/home/naresh/Camera"; # Which folder to add to Syncthing
          devices = [ "RMX3312" ]; # Which devices to share the folder with
        };
        "tpz2c-x9q93" = {
          label = "Sync_M_L";
          path = "/home/naresh/Data/Sync_M_L";
          devices = [ "RMX3312" ];
        };
        "7snbs-p6fiq" = {
          label = "Sync_M_L_C";
          path = "/home/naresh/Data/Sync_M_L_C";
          devices = [ "RMX3312" ];
        };
      };
    };
  };



}
