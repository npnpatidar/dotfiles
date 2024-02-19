{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.masterpdfeditor;
in
{
  options.modules.home-manager.masterpdfeditor = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # masterpdfeditor
      # masterpdfeditor4
      (import ../../pkgs/masterpdfeditor.nix { inherit pkgs; })
    ];
    # home.file.".config/Code Industry/Master PDF Editor 5.conf".source = ../../.secrets + "/Master PDF Editor 5.conf";
    home.file.".config/Code Industry/Master PDF Editor 5.conf".source = config.lib.file.mkOutOfStoreSymlink ../../.secrets + "/Master PDF Editor 5.conf";
  };
}
