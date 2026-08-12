inputs:
let
  base16Scheme =
    pkgs:
    pkgs.fetchFromGitHub {
      owner = "tinted-theming";
      repo = "base16-schemes";
      rev = "2b6f2d0677216ddda50c9cabd6ee70fae4665f81";
      sha256 = "sha256-VTczZi1C4WSzejpTFbneMonAdarRLtDnFehVxWs6ad0=";
    }
    + "/ocean.yaml";
in
{
  flake.nixosModules.stylix = { pkgs, ... }: {
    stylix = {
      enable = true;
      image = inputs.self.wallpapers.abstract-swirls pkgs;
      base16Scheme = base16Scheme pkgs;
      fonts.sizes = {
        desktop = 13;
        applications = 13;
        terminal = 14;
        popups = 12;
      };
      opacity = {
        terminal = 0.97;
        applications = 0.90;
        popups = 0.50;
        desktop = 0.90;
      };
      autoEnable = true;
      targets.regreet.enable = false; # we use noctalia-greeter, not regreet; avoids obsolete `programs.regreet` trace
    };
  };

  flake.homeModules.stylix = { pkgs, ... }: {
    stylix = {
      enable = true;
      image = inputs.self.wallpapers.abstract-swirls pkgs;
      polarity = "dark";
      targets = {
        zen-browser.enable = false;
        neovim.enable = false;
        librewolf.profileNames = [ "default" ];
      };
    };
  };
}
