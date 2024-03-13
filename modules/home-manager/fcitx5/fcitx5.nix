{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.fcitx5;
in
{
  options.modules.home-manager.fcitx5 = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    home.file.".config/fcitx5/profile".source = config.lib.file.mkOutOfStoreSymlink ./profile;
    home.file.".config/fcitx5/config".source = config.lib.file.mkOutOfStoreSymlink ./config;

    #   text = ''
    #     [Groups/0]
    #     # Group Name
    #     Name=Default
    #     # Layout
    #     Default Layout=in-eng
    #     # Default Input Method
    #     DefaultIM=m17n_hi_itrans
    #
    #     [Groups/0/Items/0]
    #     # Name
    #     Name=keyboard-in-eng
    #     # Layout
    #     Layout=
    #
    #     [Groups/0/Items/1]
    #     # Name
    #     Name=m17n_hi_itrans
    #     # Layout
    #     Layout=
    #
    #     [GroupOrder]
    #     0=Default
    #   '';
    #
    #

    # };
  };
}
