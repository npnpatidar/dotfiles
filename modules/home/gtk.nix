_: {
  flake.homeModules.gtk =
    { pkgs, ... }:
    {
      gtk.enable = true;
      xdg.configFile."gtk-3.0/gtk.css".force = true;
      xdg.configFile."gtk-4.0/gtk.css".force = true;

      # GTK3 aborts the whole process (g_error in ensure_surface_for_gicon) when
      # it finds an icon it cannot render. adw-gtk3 uses symbolic SVG assets and
      # GTK looks up the symbolic icons in the Adwaita theme, so both a complete
      # icon theme and SVG support are required.
      home.packages = [
        pkgs.adwaita-icon-theme
      ];

      # nixpkgs' gdk-pixbuf has no SVG loader, librsvg ships its own cache.
      home.sessionVariables.GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };
}
