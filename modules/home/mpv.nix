_: {
  flake.homeModules.mpv = { pkgs, ... }: {
    programs.mpv = {
      enable = true;
      config = {
        profile = "gpu-hq";
        vo = "gpu";
        hwdec = "auto-safe";
      };
      scripts = with pkgs.mpvScripts; [
        mpris
        cutter
        sponsorblock
      ];
      bindings = {
        "UP" = "add volume 2";
        "DOWN" = "add volume -2";
        "LEFT" = "seek -10";
        "RIGHT" = "seek 10";
        "SPACE" = "cycle pause";
        "ENTER" = "cycle pause";
        "Alt+UP" = "add volume 5";
        "Alt+DOWN" = "add volume -5";
        "Alt+RIGHT" = "seek 60";
        "Alt+LEFT" = "seek -60";
        "o" = "cycle video-unscaled";
        "a" = "cycle_values video-aspect '16:9' '4:3' '2.35:1' '-1'";
        "t" = "show_progress";
        "s" = "cycle sub";
        "b" = "cycle audio";
        "m" = "cycle mute";
        "f" = "cycle fullscreen";
        "k" = "script-binding stats/display-page-4";
      };
    };
  };
}
