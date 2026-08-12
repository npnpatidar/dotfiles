{ lib, ... }: {
  flake.homeModules.zathura =
    _: with lib; {
      programs.zathura = {
        enable = mkDefault true;
        options = { };
        extraConfig = ''
          set recolor false
          set recolor-keephue false
          set window-height 3000
          set window-width 3000
          set scroll-step 100
          set adjust-open "width"

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
    };
}
