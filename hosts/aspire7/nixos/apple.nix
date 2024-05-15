{ pkgs, ... }:
{

  # Enable Apple devices support
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };
}
