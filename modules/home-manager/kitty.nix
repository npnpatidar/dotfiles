{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.kitty;
in
{
  options.modules.home-manager.kitty = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "FiraCode";
        size = 13;
        package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      };
      theme = "Tokyo Night Storm";
      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
      settings = {
        background_opacity = "0.95";
        copy_on_select = true;
      };
      keybindings = {
        "ctrl+alt+d" = "launch --location=hsplit --copy-env";
        "shift+cmd+," = "kitten config.py --info --config --actions --no-deleted";
        "ctrl+alt+z" = "toggle_layout splits";
        "ctrl+alt+r" = "launch --location=vsplit --copy-env";
      };

    };
    home.file."kitty_config".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/ershov/kitty_config/main/config.py";
      sha256 = "sha256-NhEBQ757IiFwn92yKxxxwcnTF7jkLv2BRhHJCl7oTvg=";
    };
    home.file."kitty_config".target = ".config/kitty/config.py";

  };
}



