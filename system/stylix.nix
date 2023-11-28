{pkgs, ... }:

{

  stylix = {
    autoEnable = true;
    image = pkgs.fetchurl {
      url = "https://wallpapers.com/images/featured-full/link-16mi3e7v5hxno9c4.jpg";
      sha256 = "sha256-F7IXrWplXYpChQg0r2RwTta3w5uU+oDIlbS6k5Gs3Ew=";
    };

    polarity = "dark";

    fonts = {
      serif = {
        name = "Cantarell";
        package = pkgs.cantarell-fonts;
      };

      sansSerif = {
        name = "Cantarell";
        package = pkgs.cantarell-fonts;
      };

      monospace = {
        name = "Fira Code";
        package = pkgs.fira-code;
      };

      sizes = {
        applications = 11;
        desktop = 11;
      };
    };
  };
}
