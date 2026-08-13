_: {
  # Removable-media support (USB pendrives etc.): udisks2 is the system
  # daemon, gvfs gives Nemo a proper devices sidebar. The udiskie
  # auto-mount daemon runs in the user session.
  flake.nixosModules.removable-media = {
    services = {
      udisks2.enable = true;
      gvfs.enable = true;
      upower.enable = true;
    };
  };

  flake.homeModules.removable-media = {
    # Auto-mount removable drives (USB pendrives) on insertion.
    services.udiskie = {
      enable = true;
      settings.program_options = {
        automount = true;
        notify = true;
        tray = false;
      };
      tray = "auto";
    };
  };
}
