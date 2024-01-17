{ config, pkgs, lib, ... }:
let
  pkg = pkgs.librewolf-unwrapped;
  extraPrefs = ''
    lockPref('media.peerconnection.enabled', false);
    lockPref("privacy.resistFingerprinting", false);

    lockPref("privacy.clearOnShutdown.cache", false);
    lockPref("privacy.clearOnShutdown.cookies", false);
    lockPref("privacy.clearOnShutdown.history", false);
    lockPref("privacy.clearOnShutdown.downloads", false);

    lockPref("svg.context-properties.content.enabled", true);

    lockPref("permissions.default.geo", 2);

    lockPref("identity.fxaccounts.enabled", true);

    lockPref("browser.compactmode.show", true);
    lockPref("browser.tabs.tabmanager.enabled", false);

    lockPref("xpinstall.enabled", false);
    lockPref("xpinstall.whitelist.required", true);
  '';
  extraPolicies = {
    AppAutoUpdate = false;
    ExtensionSettings = {
      "uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      };
      "addon@darkreader.org" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
      };
    };
  };

  # By default, extraPolicies & extraPrefs in firefox-wrapper will **override** prebuilts.
  # This is not convenient as prebuilts are also required for librewolf.
  # So I rewrite the logic of extraPolicies & extraPrefs to ship both prebuilts and custom hacks together :)
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
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkg {
      inherit (pkg)
        ;
      wmClass = "LibreWolf";
      libName = "librewolf";

      extraPoliciesFiles = [ overallPolicyFile ];
      extraPrefsFiles = [ overallPrefsFile ];
    };
  };

  home.packages = with pkgs; [ speechd ];
}
