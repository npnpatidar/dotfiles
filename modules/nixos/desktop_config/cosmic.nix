{ config
, pkgs
, lib
, ...
}: {
  # components that need to be in PATH
  environment.systemPackages = with pkgs; [
    cosmic-applibrary
    cosmic-applets
    cosmic-bg
    cosmic-comp
    cosmic-edit
    cosmic-files
    cosmic-greeter
    cosmic-icons
    cosmic-launcher
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-randr
    cosmic-screenshot
    cosmic-settings
    cosmic-settings-daemon
    cosmic-term
    cosmic-workspaces-epoch
    cosmic-applets
    cosmic-applibrary
    cosmic-bg
    cosmic-comp
    cosmic-icons
    cosmic-launcher
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-session
    cosmic-settings
    cosmic-settings-daemon
    cosmic-workspaces-epoch
    xdg-desktop-portal-cosmic
    cosmic-greeter
    cosmic-protocols
    cosmic-edit
    cosmic-screenshot
    cosmic-design-demo
    cosmic-term
    cosmic-randr
    cosmic-files
    cosmic-applets
    cosmic-applibrary
    cosmic-bg
    cosmic-comp
    cosmic-edit
    cosmic-files
    cosmic-greeter
    cosmic-icons
    cosmic-launcher
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-randr
    cosmic-screenshot
    cosmic-session
    cosmic-settings
    cosmic-settings-daemon
    cosmic-term
    cosmic-workspaces-epoch
    gnome.adwaita-icon-theme
    hicolor-icon-theme
    pop-icon-theme
    pop-launcher

  ];

  # COSMIC portal doesn't support everything yet
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-cosmic
    xdg-desktop-portal-gtk
  ];
  xdg.portal.configPackages = with pkgs; [
    xdg-desktop-portal-cosmic
  ];

  # session files for display manager and systemd

  services.xserver.displayManager = {
    sessionPackages = with pkgs;[ cosmic-session ];
    autoLogin.enable = true;
    autoLogin.user = "naresh";
  };
  systemd.packages = with pkgs; [ cosmic-session ];

  # services.xserver.displayManager.cosmic-greeter.enable = true;
  # services.xserver.desktopManager.cosmic.enable = true;
  security.pam.services.cosmic-greeter = { };
}

