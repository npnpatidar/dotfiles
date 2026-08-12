{ lib, ... }: with lib;
{
  flake.nixosModules.time-locale = { pkgs, ... }: {
    time.timeZone = "Asia/Kolkata";

    i18n = {
      defaultLocale = "en_IN";
      extraLocaleSettings = {
        LC_ADDRESS = "en_IN";
        LC_IDENTIFICATION = "en_IN";
        LC_MEASUREMENT = "en_IN";
        LC_MONETARY = "en_IN";
        LC_NAME = "en_IN";
        LC_NUMERIC = "en_IN";
        LC_PAPER = "en_IN";
        LC_TELEPHONE = "en_IN";
        LC_TIME = "en_IN";
      };
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          ignoreUserConfig = true;
          addons = with pkgs; [
            fcitx5-gtk
            fcitx5-m17n
          ];
          settings = {
            inputMethod = {
              "Groups/0" = {
                Name = "Default";
                "Default Layout" = "us";
                DefaultIM = "keyboard-us";
              };
              "Groups/0/Items/0".Name = "keyboard-us";
              "Groups/0/Items/1".Name = "m17n_hi_itrans";
              GroupOrder."0" = "Default";
            };
            globalOptions = {
              "Hotkey/TriggerKeys"."0" = "Control+space";
              "Hotkey/AltTriggerKeys"."0" = "Shift+Shift_L";
              "Hotkey/PrevCandidate"."0" = "Shift+Tab";
              "Hotkey/NextCandidate"."0" = "Tab";
              "Behavior".ActiveByDefault = "False";
              "Behavior".ShareInputState = "No";
              "Behavior".PreeditEnabledByDefault = "True";
              "Behavior".ShowInputMethodInformation = "True";
              "Behavior".CompactInputMethodInformation = "True";
              "Behavior".ShowFirstInputMethodInformation = "True";
              "Behavior".DefaultPageSize = "4";
              "Behavior".PreloadInputMethod = "True";
              "Behavior".AutoSavePeriod = "30";
            };
          };
        };
      };
    };

    services.libinput = {
      enable = true;
      touchpad = {
        tappingDragLock = false;
        naturalScrolling = true;
      };
    };
  };
}
