{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.vscode;
in
{
  options.modules.home-manager.vscode = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium-fhs;
      extensions = with pkgs.vscode-extensions;[
        mhutchie.git-graph
        github.vscode-pull-request-github
        esbenp.prettier-vscode
        arrterian.nix-env-selector
        mkhl.direnv
        jnoortheen.nix-ide
        ms-python.python

      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "codeium";
          publisher = "codeium";
          version = "1.4.23";
          sha256 = "sha256-HZpBZy6n8YBOA2t4klccqlGISzEq3MjOBVjPECOdBcI=";
        }
        {
          name = "nix-ide";
          publisher = "jnoortheen";
          version = "0.2.2";
          sha256 = "sha256-jwOM+6LnHyCkvhOTVSTUZvgx77jAg6hFCCpBqY8AxIg=";
        }

      ];
    };
  };
}
