{ config, lib, ... }:

with lib;
let
  cfg = config.modules.home-manager.xdg;
in
{
  options.modules.home-manager.xdg = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    xdg.enable = true;
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_VMSHARE_DIR = "${config.home.homeDirectory}/VMShare";
        XDG_DESKTOP_DIR = "${config.home.homeDirectory}/Desktop";
        XDG_DOWNLOAD_DIR = "${config.home.homeDirectory}/Downloads";
        XDG_TEMPLATES_DIR = "${config.home.homeDirectory}/Templates";
        XDG_PUBLICSHARE_DIR = "${config.home.homeDirectory}/Public";
        XDG_DOCUMENTS_DIR = "${config.home.homeDirectory}/Documents";
        XDG_MUSIC_DIR = "${config.home.homeDirectory}/Music";
        XDG_PICTURES_DIR = "${config.home.homeDirectory}/Pictures";
        XDG_VIDEOS_DIR = "${config.home.homeDirectory}/Videos";
      };
    };

    xdg.mime.enable = true;
    xdg.configFile."mimeapps.list".force = true;
    xdg.mimeApps = {
      enable = true;
      associations.added = {
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/chrome" = "librewolf.desktop";
        "text/html" = "librewolf.desktop";
        "application/x-extension-htm" = "librewolf.desktop";
        "application/x-extension-html" = "librewolf.desktop";
        "application/x-extension-shtml" = "librewolf.desktop";
        "application/xhtml+xml" = "librewolf.desktop";
        "application/x-extension-xhtml" = "librewolf.desktop";
        "application/x-extension-xht" = "librewolf.desktop";
      };
      defaultApplications = {
        "image/*" = [ "feh.desktop" ];
        "application/pdf" = [ "sioyek.desktop" "org.pwmt.zathura.desktop" "masterpdfeditor5.desktop" ];
        "text/plain" = [ "notepadqq.desktop" ];
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        "x-scheme-handler/http" = [ "librewolf.desktop" ];
        "x-scheme-handler/https" = [ "librewolf.desktop" ];
        "x-scheme-handler/chrome" = [ "librewolf.desktop" ];
        "text/html" = [ "librewolf.desktop" ];
        "application/x-extension-htm" = [ "librewolf.desktop" ];
        "application/x-extension-html" = [ "librewolf.desktop" ];
        "application/x-extension-shtml" = [ "librewolf.desktop" ];
        "application/xhtml+xml" = [ "librewolf.desktop" ];
        "application/x-extension-xhtml" = [ "librewolf.desktop" ];
        "application/x-extension-xht" = [ "librewolf.desktop" ];
        "audio/*" = [ "vlc.desktop" ];
        "video/*" = [ "vlc.desktop" ];

      };
    };

    xdg.desktopEntries = {
      "btop" = {
        exec = "";
        name = "btop++";
        settings.NoDisplay = "true";
      };

      "xterm" = {
        exec = "";
        name = "XTerm";
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

      "mupdf" = {
        exec = "";
        name = "mupdf";
        settings.NoDisplay = "true";
      };

      "org.gnome.Meld" = {
        exec = "meld %F";
        name = "Meld";
        settings.NoDisplay = "true";
      };

      "org.gnome.Tour" = {
        exec = "";
        name = "Tour";
        settings.NoDisplay = "true";
      };


      "kbd-layout-viewer5" = {
        exec = "";
        name = "Keyboard layout viewer";
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

}
