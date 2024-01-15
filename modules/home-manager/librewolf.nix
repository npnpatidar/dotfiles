{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.librewolf;
in
{

  options.modules.home-manager.librewolf = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {


    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.librewolf-unwrapped {
        inherit (pkgs.librewolf-unwrapped) extraPrefsFiles extraPoliciesFiles;
        wmClass = "LibreWolf";
        libName = "librewolf";
      };
      policies = {
        ExtensionSettings = with builtins;
          let extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "normal_installed";
            };
          };
          in
          listToAttrs [
            (extension "tabliss" "extension@tabliss.io")
            (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
            (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
          ];
      };
    };
  };
}
