{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.qutebrowser;
in
{
  options.modules.home-manager.qutebrowser = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      bitwarden-cli
      keyutils
      python3Packages.tldextract
    ];

    programs.qutebrowser = {
      enable = true;


      package = pkgs.qutebrowser;
      loadAutoconfig = true; # For notification prompts
      searchEngines.DEFAULT = "https://startpage.com/search?q={}";
      searchEngines = {
        w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
        aw = "https://wiki.archlinux.org/?search={}";
        np = "https://search.nixos.org/packages?&query={}";
        nw = "https://nixos.wiki/index.php?search={}";
        hm = "https://mipmip.github.io/home-manager-option-search/?query={}";
        g = "https://www.google.com/search?hl=en&q={}";
        b = "https://search.brave.com/search?q={}";
        s = "https://startpage.com/search?q={}";
        e = "https://ecosia.org/search?&q={}";
        d = "https://docs.rs/releases/search?query={}";
      };

      settings = {
        auto_save.session = false;
        session.lazy_restore = true;
        statusbar.show = "in-mode";
        downloads.position = "bottom";
        url.start_pages = "https://startpage.com";
        tabs = {
          show = "multiple";
          show_switching_delay = 1500;
          background = true;
          title.format = "{audio}{current_title}";
        };
        scrolling.smooth = true;
        spellcheck.languages = [ "en-US" "hi-IN" ];
        content.autoplay = false;
        content.blocking = {
          enabled = true;
          method = "both";
          adblock.lists = [
            "https://easylist.to/easylist/easylist.txt"
            "https://easylist.to/easylist/easyprivacy.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt"
            "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"
            "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
            "https://hosts.netlify.app/Pro/adblock.txt"
            "https://filters.adtidy.org/extension/ublock/filters/2.txt"
          ];
        };
      };

      keyBindings = {
        normal = {
          "gk" = "scroll-to-perc 0";
          "gj" = "scroll-to-perc 100";
          "e" = "config-cycle statusbar.show always never";
          "E" = "config-cycle tabs.position right top";
          # "z" = "spawn --userscript qute-bitwarden";
          ",pp" = "spawn --userscript qute-bitwarden -t";
          ",pu" = "spawn --userscript qute-bitwarden --username-only";
          ",ps" = "spawn --userscript qute-bitwarden --password-only";
          ",pt" = "spawn --userscript qute-bitwarden --totp-only";
          # "<Ctrl-v>" = "spawn mpv {url}";
          # ",p" = "spawn --userscript qute-bitwarden";
          # ",u" = "adblock-update";
          # ",l" =
          #   ''config-cycle spellcheck.languages ["en-GB"] ["en-US"] ["pl-PL"]'';
          # "wd" =
          #   "hint links spawn kitty -e ${pkgs.yt-dlp}/bin/yt-dlp {hint-url}"; # make it more terminal agnostic
          # "ww" = "hint links spawn --detach mpv {hint-url}";
          # "ws" =
          #   "hint links spawn --detach ${pkgs.streamlink}/bin/streamlink {hint-url} best --player mpv";
          "q" = "tab-close";
          "+" = "zoom-in";
          "-" = "zoom-out";
        };
        prompt = { "<Ctrl-y>" = "prompt-yes"; };
      };

    };


  };
}











