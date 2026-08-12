_: {
  flake.homeModules.geary = { pkgs, ... }: {
    home.packages = [ pkgs.geary ];
    home.file.".config/geary/user-style.css".text = ''
      :root *:not(a) {
        color: #eeeeec !important;
        background-color: #3B4252 !important;
      }
    '';
  };
}
