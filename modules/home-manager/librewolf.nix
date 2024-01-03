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
      package = pkgs.librewolf;
      profiles.default = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          aria2-integration
          buster-captcha-solver
          clearurls
          decentraleyes
          #  absolute-enable
          bitwarden
          #  bypass-paywall
          darkreader
          duckduckgo-privacy-essentials
          floccus
          i-dont-care-about-cookies
          omnivore
          #  startpage-privacy-essentials
          #  autofill

          libredirect

          ublock-origin

          # # Missing:
          # cloudhole
          # devtools-adb-extension
          # firefox-sticky-window-containers

        ];

        settings = {
          "browser.startup.homepage" = "https://nixos.org";
          "browser.search.region" = "IN";
          "browser.search.isUS" = false;
          "distribution.searchplugins.defaultLocale" = "en-IN";
          "general.useragent.locale" = "en-IN";
          "browser.bookmarks.showMobileBookmarks" = true;
          "browser.newtabpage.pinned" = [{
            title = "NixOS";
            url = "https://nixos.org";
          }];
        };
      };
    };
  };
}
