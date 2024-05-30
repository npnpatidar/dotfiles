{ pkgs, ... }:
{


  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      # nerdfonts
      (import ../../../pkgs/sahityaFont.nix { inherit pkgs; })
      (pkgs.nerdfonts.override {
        fonts = [ "FiraCode" "NerdFontsSymbolsOnly" ];
      })
      # lohit-fonts.devanagari
      # (pkgs.noto-fonts.override {
      #   variants = [ "Noto Sans Symbols" "Noto Sans Symbols 2" "Noto Sans Math" "Noto Sans Devanagari" "Noto Serif Devanagari" ];
      # })
      # noto-fonts
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "FiraCode Nerd Font" "Sahitya" ];
        sansSerif = [ "FiraCode Nerd Font" "Sahitya" ];
        monospace = [ "FiraCode Nerd Font Mono" "Sahitya" ];
      };
    };
  };

}
