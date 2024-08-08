{ config, pkgs, lib, ... }:

{

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    nvidiaPersistenced = true;
    prime = {
      # offload = # run program as nvidia-offload  glxgears
      #   {
      #     enable = true;
      #     enableOffloadCmd = true;
      # };
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };


  # specialisation = {      #special on-the-go mode which  enable offload mode 
  # 	on-the-go.configuration = {      
  # 		system.nixos.tags = [ "on-the-go" ];
  # 		hardware.nvidia = {
  # 			prime.offload.enable = lib.mkForce true;
  # 			prime.offload.enableOffloadCmd = lib.mkForce true;
  # 			prime.sync.enable = lib.mkForce false;
  # 	 };
  # 	};
  # };


}
