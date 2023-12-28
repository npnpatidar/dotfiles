{ config, pkgs, ... }:
{
  home.file.".config/Code Industry/Master PDF Editor 5.conf" = {
    # source = "../../../.secrets/Master PDF Editor 5.conf";
    source = config.lib.file.mkOutOfStoreSymlink ../../.secrets + "/Master PDF Editor 5.conf";
    # executable = true;
  };
}
