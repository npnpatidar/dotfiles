{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.librewolf;
  pkg = pkgs.librewolf-unwrapped;
  extraPrefs = ''
    lockPref("identity.fxaccounts.enabled", true);
  '';
  extraPolicies = {
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
        # (extension "darkreader" "addon@darkreader.org")
        (extension "absolute-enable-right-click" "{9350bc42-47fb-4598-ae0f-825e3dd9ceba}")
        (extension "bypass-paywalls-clean-d" "magnolia_limited_permissions_d@12.34")
        (extension "i-dont-care-about-cookies" "jid1-KKzOGWgsW3Ao4Q@jetpack")
        (extension "tridactyl-vim" "tridactyl.vim@cmcaine.co.uk")
        (extension "autofill-quantum" "{143f479b-4cb2-4d8c-8c31-ae8653bc6054}")
        (extension "imagus" "{00000f2a-7cde-4f20-83ed-434fcb420d71}")
        (extension "omnivore" "save-extension@omnivore.app")
        (extension "midnight-lizard-quantum" "{8fbc7259-8015-4172-9af1-20e1edfbbd3a}")
      ];
    AppAutoUpdate = false;
  };

  recursiveMerges = attrList:
    let
      f = attrPath:
        lib.zipAttrsWith (n: values:
          if lib.tail values == [ ] then
            lib.head values
          else if lib.all lib.isList values then
            lib.unique (lib.concatLists values)
          else if lib.all lib.isAttrs values then
            f (lib.attrPath ++ [ n ]) values
          else
            lib.last values);
    in
    f [ ] attrList;
  shippedPoliciesJSON = builtins.fromJSON
    (builtins.readFile (builtins.concatStringsSep "" pkg.extraPoliciesFiles));
  customPoliciesJSON = { policies = extraPolicies; };
  overallPolicyFile = pkgs.writeText "policy.json" (builtins.toJSON
    (recursiveMerges [ shippedPoliciesJSON customPoliciesJSON ]));

  shippedPrefs =
    builtins.readFile (builtins.concatStringsSep "" pkg.extraPrefsFiles);
  overallPrefsFile = pkgs.writeText "librewolf.cfg"
    (builtins.concatStringsSep "" [ shippedPrefs extraPrefs ]);
in
{
  options.modules.home-manager.librewolf = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkg {
        inherit (pkg);
        wmClass = "LibreWolf";
        libName = "librewolf";

        extraPoliciesFiles = [ overallPolicyFile ];
        extraPrefsFiles = [ overallPrefsFile ];
      };
    };

  };
}
