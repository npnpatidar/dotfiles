{ pkgs, ... }:
{
  home.packages = with pkgs;[
    texliveMedium
    gnome-latex
  ];


}
