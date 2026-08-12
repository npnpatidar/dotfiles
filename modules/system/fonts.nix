_: {
  flake.nixosModules.fonts =
    { pkgs, ... }:
    let
      sahitya = import ../../pkgs/sahityaFont.nix { inherit pkgs; };
    in
    {
      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          sahitya
          nerd-fonts.fira-code
          nerd-fonts.symbols-only
          corefonts
        ];
        fontconfig.enable = true;
        fontconfig.defaultFonts = {
          serif = [
            "FiraCode Nerd Font"
            "Sahitya"
          ];
          sansSerif = [
            "FiraCode Nerd Font"
            "Sahitya"
          ];
          monospace = [
            "FiraCode Nerd Font Mono"
            "Sahitya"
          ];
        };
      };

      system.userActivationScripts = {
        copy-fonts-local-share = {
          text = ''
            chmod -R u+w ~/.local/share/fonts 2>/dev/null || true
            rm -rf ~/.local/share/fonts
            mkdir -p ~/.local/share/fonts
            cp ${pkgs.corefonts}/share/fonts/truetype/* ~/.local/share/fonts/
            cp ${sahitya}/share/fonts/truetype/* ~/.local/share/fonts/
            chmod 544 ~/.local/share/fonts
            chmod 444 ~/.local/share/fonts/*
          '';
        };
      };
    };
}
