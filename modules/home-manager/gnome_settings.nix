{ config, pkgs, ... }:

{
  gtk = {
    enable = true;

  };
  # dconf.nix is created by command: 
  #dconf dump / | dconf2nix > ~/dotfiles/modules/home-manager/dconf.nix
  imports = [ ./dconf.nix ];

  xdg.configFile."tiling-assistant/layout.json".text = ''

[{"_name":"Master and Stack [V]","_items":[{"rect":{"x":0,"y":0,"width":0.5,"height":1},"appId":null,"loopType":null},{"rect":{"x":0.5
       │ ,"y":0,"width":0.5,"height":1},"appId":null,"loopType":"h"}]},{"_name":"N-Columns","_items":[{"rect":{"x":0,"y":0,"width":1,"height":1
       │ },"appId":null,"loopType":"v"}]},{"_name":"2 : 1 [V]","_items":[{"rect":{"x":0,"y":0,"width":0.66,"height":1},"appId":null,"loopType":
       │ null},{"rect":{"x":0.66,"y":0,"width":0.34,"height":1},"appId":null,"loopType":null}]},{"_name":"4 Quarters","_items":[{"rect":{"x":0,
       │ "y":0,"width":0.5,"height":0.5},"appId":null,"loopType":null},{"rect":{"x":0.5,"y":0,"width":0.5,"height":0.5},"appId":null,"loopType"
       │ :null},{"rect":{"x":0,"y":0.5,"width":0.5,"height":0.5},"appId":null,"loopType":null},{"rect":{"x":0.5,"y":0.5,"width":0.5,"height":0.
       │ 5},"appId":null,"loopType":null}]}]
    '';



  # home.packages = (with pkgs;[
  #   nordic
  # ]) ++ (with pkgs.gnome;[
  #   adwaita-icon-theme
  #   nautilus
  #   gnome-tweaks
  #   dconf-editor
  #   gnome-control-center
  #   gnome-shell-extensions
  #   seahorse
  #
  #
  # ]) ++ (with pkgs.gnomeExtensions;[
  #   appindicator
  #   dash-to-panel
  #   blur-my-shell
  #   net-speed-simplified
  #   user-themes
  #   pano
  # ]);
  #




}
