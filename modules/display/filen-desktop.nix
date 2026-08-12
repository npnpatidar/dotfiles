_: {
  flake.homeModules.filen-desktop = { pkgs, ... }: {
    systemd.user.services.filen-desktop = {
      Unit = {
        Description = "Filen Desktop";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.filen-desktop}/bin/filen-desktop";
        Restart = "on-failure";
        RestartSec = "5";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
