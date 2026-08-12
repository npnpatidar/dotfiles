{ lib, ... }: with lib;
{
  flake.nixosModules.syncthing = { config, ... }: {
    services.syncthing = {
      enable = true;
      guiAddress = "0.0.0.0:8384";
      user = "${config.systemConstants.default_user}";
      dataDir = "${config.systemConstants.data_directory}";
      configDir = "${config.systemConstants.home_directory}/.config/syncthing";
      settings.gui = {
        user = "${config.systemConstants.default_user}";
        password = "$2b$10$iilNrfyms.rPHAGyONsuAumN86JXCvUF29.TLUH93Pv2aUMseWqyy";
      };
      settings.devices = {
        "android" = {
          id = "HCTJGO3-5EH5OUZ-7LZW4NT-CQ3LAYO-LKKQUBJ-4YK3LIZ-JLEQCUC-DTUE4QA";
          name = "android";
          autoAcceptFolders = false;
          addresses = [
            "dynamic"
            "tcp://android.n:22000"
          ];
        };
        "ipad" = {
          id = "EYUCT6O-SQMOKM2-UWA5QAN-OVFGS3G-NNKX5RC-IBL5FLF-LD3YR55-LLMJOA4";
          name = "ipad";
          autoAcceptFolders = false;
          addresses = [
            "dynamic"
            "tcp://ipad.n:22000"
          ];
        };
      };
    };
  };
}
