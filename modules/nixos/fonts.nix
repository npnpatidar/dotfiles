{ pkgs, ... }:
{


  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerdfonts
      lohit-fonts.devanagari
      noto-fonts
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "FiraCode Nerd Font" "Lohit Devanagari" ];
        sansSerif = [ "FiraCode Nerd Font" "Lohit Devanagari" ];
        monospace = [ "FiraCode Nerd Font Mono" "Lohit Devanagari" ];
      };
    };
  };

}
