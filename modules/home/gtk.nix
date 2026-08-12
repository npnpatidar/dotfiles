_: {
  flake.homeModules.gtk = _: {
    gtk.enable = true;
    xdg.configFile."gtk-3.0/gtk.css".force = true;
    xdg.configFile."gtk-4.0/gtk.css".force = true;
  };
}
