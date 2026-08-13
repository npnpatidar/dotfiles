_: {
  flake.homeModules.xdg = { config, ... }: {
    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        extraConfig = {
          VMSHARE = "${config.home.homeDirectory}/VMShare";
        };
      };
      mime.enable = true;
      configFile."mimeapps.list".force = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "image/gif" = "imv-dir.desktop";
          "image/jpeg" = "imv-dir.desktop";
          "image/jpg" = "imv-dir.desktop";
          "image/png" = "imv-dir.desktop";
          "image/svg+xml" = "librewolf.desktop";
          "image/tiff" = "imv-dir.desktop";
          "image/vnd.microsoft.icon" = "imv-dir.desktop";
          "image/webp" = "imv-dir.desktop";
          "image/*" = [ "imv-dir.desktop" ];
          "application/pdf" = [ "sioyek.desktop" ];
          "text/plain" = [ "dev.zed.Zed.desktop" ];
          "inode/directory" = [ "nemo.desktop" ];
          "x-scheme-handler/http" = [ "librewolf.desktop" ];
          "x-scheme-handler/https" = [ "librewolf.desktop" ];
          "x-scheme-handler/chrome" = [ "librewolf.desktop" ];
          "text/html" = [ "librewolf.desktop" ];
          "text/markdown" = [ "dev.zed.Zed.desktop" ];
          "application/x-extension-htm" = [ "librewolf.desktop" ];
          "application/x-extension-html" = [ "librewolf.desktop" ];
          "application/x-extension-shtml" = [ "librewolf.desktop" ];
          "application/xhtml+xml" = [ "librewolf.desktop" ];
          "application/x-extension-xhtml" = [ "librewolf.desktop" ];
          "application/x-extension-xht" = [ "librewolf.desktop" ];
          "audio/*" = [ "mpv.desktop" ];
          "video/*" = [ "mpv.desktop" ];
          "application/msword" = [ "onlyoffice-desktopeditors.desktop" ];
          "application/vnd.ms-word.document.macroEnabled.12" = [ "onlyoffice-desktopeditors.desktop" ];
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
            "onlyoffice-desktopeditors.desktop"
          ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
            "onlyoffice-desktopeditors.desktop"
          ];
          "application/vnd.ms-excel" = [ "onlyoffice-desktopeditors.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
            "onlyoffice-desktopeditors.desktop"
          ];
          "application/vnd.ms-powerpoint" = [ "onlyoffice-desktopeditors.desktop" ];
          "application/vnd.oasis.opendocument.text" = [ "onlyoffice-desktopeditors.desktop" ];
          "application/vnd.oasis.opendocument.spreadsheet" = [ "onlyoffice-desktopeditors.desktop" ];
          "application/vnd.oasis.opendocument.presentation" = [ "onlyoffice-desktopeditors.desktop" ];
          "text/csv" = [ "onlyoffice-desktopeditors.desktop" ];
        };
        associations.removed = {
          "application/pdf" = [ "Chromium.desktop" ];
        };
      };
      desktopEntries = {
        "btop" = {
          exec = "";
          name = "btop++";
          settings.NoDisplay = "true";
        };
        "cups" = {
          exec = "";
          name = "Manage Printing";
          settings.NoDisplay = "true";
        };
        "ranger" = {
          exec = "";
          name = "ranger";
          settings.NoDisplay = "true";
        };
        "org.gnome.Meld" = {
          exec = "meld %F";
          name = "Meld";
          settings.NoDisplay = "true";
        };
        "gparted" = {
          exec = "";
          name = "Gparted";
          settings.NoDisplay = "true";
        };
        "fcitx5-configtool" = {
          exec = "";
          name = "Fcitx 5 Configuration";
          settings.NoDisplay = "true";
        };
        "org.fcitx.fcitx5-migrator" = {
          exec = "";
          name = "Fcitx 5 Migration Wizard";
          settings.NoDisplay = "true";
        };
        "org.fcitx.Fcitx5" = {
          exec = "";
          name = "Fcitx 5";
          settings.NoDisplay = "true";
        };
        "nvim" = {
          exec = "";
          name = "Neovim wrapper";
          settings.NoDisplay = "true";
        };
      };
    };
  };
}
