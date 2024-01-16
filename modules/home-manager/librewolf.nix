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
              installation_mode = "force_installed";
            };
          };
          in
          listToAttrs [
            (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
            (extension "xdm-browser-monitor-v8" "xdm-v8-browser-helper@subhra74.github.io")
            (extension "floccus" "floccus@handmadeideas.org")
            (extension "skip-redirect" "skipredirect@sblask")
            (extension "darkreader" "addon@darkreader.org")
            (extension "absolute-enable-right-click" "{9350bc42-47fb-4598-ae0f-825e3dd9ceba}")
            (extension "bypass-paywalls-clean-d" "magnolia_limited_permissions_d@12.34")
            (extension "i-dont-care-about-cookies" "jid1-KKzOGWgsW3Ao4Q@jetpack")
            (extension "tridactyl-vim" "tridactyl.vim@cmcaine.co.uk")
            (extension "autofill-quantum" "{143f479b-4cb2-4d8c-8c31-ae8653bc6054}")
          ];
      };
    };
  };
}
