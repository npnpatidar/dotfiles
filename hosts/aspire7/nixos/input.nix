{ pkgs, ... }:
{

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_IN.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_IN.UTF-8";
      LC_IDENTIFICATION = "en_IN.UTF-8";
      LC_MEASUREMENT = "en_IN.UTF-8";
      LC_MONETARY = "en_IN.UTF-8";
      LC_NAME = "en_IN.UTF-8";
      LC_NUMERIC = "en_IN.UTF-8";
      LC_PAPER = "en_IN.UTF-8";
      LC_TELEPHONE = "en_IN.UTF-8";
      LC_TIME = "en_IN.UTF-8";
    };

    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-m17n
      ];
    };

  };

  # Configure keymap in X11 and touchpad support
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
      options = "rupeesign:e";
    };

  };
  services.libinput = {
    enable = true;
    touchpad = {
      tappingDragLock = false;
      naturalScrolling = true;
    };
  };


}
