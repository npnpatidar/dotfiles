{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.zathura;
in
{
  options.modules.home-manager.zathura = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    programs.zathura = {
      enable = lib.mkDefault true;
      options = { };
      extraConfig = ''
        set recolor false # invert colors
        set recolor-keephue false
        set window-height 3000
        set window-width 3000
        set scroll-step 100
        set adjust-open "width"


        # Define mappings for fullscreen
        map [fullscreen] b adjust_window best-fit
        map [fullscreen] w adjust_window width
        map [fullscreen] f follow
        map [fullscreen] d toggle_page_mode 2
        map [fullscreen] <Tab> toggle_index
        map [fullscreen] <C-o> jumplist backward
        map [fullscreen] <C-i> jumplist forward
        map [fullscreen] v set recolor false
        map [fullscreen] x set recolor true
        map [fullscreen] u scroll half-up
        map [fullscreen] i scroll half-down
        

        # Define mappings for normal mode 
        map [normal] b adjust_window best-fit
        map [normal] w adjust_window width
        map [normal] f follow
        map [normal] d toggle_page_mode 2
        map [normal] <Tab> toggle_index
        map [normal] <C-o> jumplist backward
        map [normal] <C-i> jumplist forward
        map [normal] i scroll half-down
        map [normal] u scroll half-up
        map [normal] x set recolor true
        map [normal] v set recolor false
      '';
    };
    # xdg.mimeApps = {
    #   defaultApplications."application/pdf" =
    #     [ "zathura.desktop" "mupdf.desktop" ];
    # };

  };
}
