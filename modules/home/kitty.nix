{ lib, ... }: {
  flake.homeModules.kitty = { pkgs, ... }: with lib;
    {
      programs.kitty = {
        enable = true;
        font = {
          name = mkDefault "FiraCode";
          size = mkForce 12;
        };
        themeFile = null;
        shellIntegration = {
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
        enableGitIntegration = true;
        extraConfig = ''
          include themes/noctalia.conf
          include power.conf
        '';
        settings = {
          background_opacity = mkDefault "0.95";
          copy_on_select = true;
        };
        keybindings = {
          "ctrl+alt+d" = "launch --location=hsplit --copy-env";
          "shift+cmd+," = "kitten config.py --info --config --actions --no-deleted";
          "ctrl+alt+z" = "toggle_layout splits";
          "ctrl+alt+r" = "launch --location=vsplit --copy-env";
        };
      };
      home.file.".config/kitty/config.py".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/ershov/kitty_config/main/config.py";
        sha256 = "sha256-NhEBQ757IiFwn92yKxxxwcnTF7jkLv2BRhHJCl7oTvg=";
      };
    };
}
