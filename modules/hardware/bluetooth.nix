_: {
  flake.nixosModules.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          ControllerMode = "dual";
          AutoEnable = true;
          FastConnectable = true;
        };
        Policy = {
          AutoEnable = true;
          AutoConnect = "input-host";
        };
      };
    };
  };
}
