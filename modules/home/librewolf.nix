{ lib, ... }: {
  flake.homeModules.librewolf = { config, pkgs, ... }: {
    programs.librewolf = {
      enable = true;
      profiles.default = {
        id = 0;
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "extensions.autoDisableScopes" = 0;
          "browser.search.defaultenginename" = "Google";
          "browser.search.selectedEngine" = "Google";
          "browser.urlbar.placeholderName" = "Google";
          "browser.search.region" = "IN";
          "browser.search.openintab" = true;
          "xpinstall.signatures.required" = false;
          "extensions.update.enabled" = false;
          "browser.quitShortcut.disabled" = true;
          "browser.uidensity" = 0;
          "browser.startup.page" = 3;
          "browser.warnOnQuitShortcut" = false;
          "identity.fxaccounts.enabled" = true;
          "webgl.disabled" = true;
          "media.peerconnection.ice.no_host" = false;
          "browser.sessionstore.resume_from_crash" = false;
          "security.OCSP.require" = false;
          "network.dns.disableIPv6" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.letterboxing" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.downloads" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "browser.display.use_document_fonts" = true;
          "pdfjs.disabled" = true;
          "media.videocontrols.picture-in-picture.enabled" = true;
          "widget.non-native-theme.enabled" = false;
          "browser.newtabpage.enabled" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "experiments.activeExperiment" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "network.allow-experiments" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          floccus
          skip-redirect
          absolute-enable-right-click
          tridactyl
          karakeep
          clearurls
          imagus
          multi-account-containers
          ublock-origin
          istilldontcareaboutcookies
          web-clipper-obsidian
          enhanced-github
          (buildFirefoxXpiAddon {
            pname = "xdm-browser-monitor-v8";
            version = "3.4";
            addonId = "xdm-v8-browser-helper@subhra74.github.io";
            url = "https://addons.mozilla.org/firefox/downloads/file/4095144/xdm_browser_monitor_v8-3.4.xpi";
            sha256 = "sha256-+3A6wX3COWADiahpU/v2PfbTEoCndFFHwRy6ky0WV8k=";
            meta = with lib; { };
          })
        ];
        extensions.force = true;
        search = {
          default = "searx";
          order = [
            "searx"
            "perplexity"
            "google"
            "chatgpt"
            "ddg"
            "github"
            ""
          ];
          engines = {
            amazon.metaData.hidden = true;
            amazondotcom-us.metaData.hidden = true;
            ebay.metaData.hidden = true;
            policy-MetaGer.metaData.hidden = true;
            policy-StartPage.metaData.hidden = true;
            policy-Mojeek.metaData.hidden = true;
            mojeek.metaData.hidden = true;
            bing.metaData.hidden = true;
            ddg.metaData.alias = "@d";
            "policy-DuckDuckGo Lite".metaData.alias = "@l";
            wikipedia.metaData.alias = "@w";
            google.metaData.alias = "@g";
            searx = {
              name = "Searx";
              urls = [
                { template = "https://searx.${config.systemConstants.domain_name}/search?q={searchTerms}"; }
              ];
              definedAliases = [ "@s" ];
              iconMapObj."16" = "https://metasearx.com/static/themes/oscar/img/logo_searx_a.png";
            };
            nixos-wiki = {
              name = "NixOS Wiki";
              urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
              definedAliases = [ "@nw" ];
              iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
            };
            nix-packages = {
              name = "Nixpkgs";
              urls = [ { template = "https://search.nixos.org/packages?query={searchTerms}"; } ];
              iconMapObj."16" = "https://search.nixos.org/favicon.png";
              definedAliases = [ "@np" ];
            };
            nixos-options = {
              name = "NixOS";
              urls = [ { template = "https://search.nixos.org/options?query={searchTerms}"; } ];
              iconMapObj."16" = "https://search.nixos.org/favicon.png";
              definedAliases = [ "@no" ];
            };
            nix-flakes = {
              name = "Nix Flakes";
              urls = [ { template = "https://search.nixos.org/flakes?query={searchTerms}"; } ];
              iconMapObj."16" = "https://search.nixos.org/favicon.png";
              definedAliases = [ "@nf" ];
            };
            github = {
              name = "GitHub";
              urls = [ { template = "https://github.com/search?type=code&q={searchTerms}"; } ];
              iconMapObj."16" = "https://github.com/favicon.ico";
              definedAliases = [ "@gh" ];
            };
            chatgpt = {
              name = "ChatGPT";
              urls = [ { template = "https://chatgpt.com/?q={searchTerms}"; } ];
              iconMapObj."16" = "https://chatgpt.com/favicon.ico";
              definedAliases = [ "@c" ];
            };
            perplexity = {
              name = "Perplexity AI";
              urls = [ { template = "https://www.perplexity.ai/search/new?pc=firefox&q={searchTerms}"; } ];
              iconMapObj."16" = "https://www.perplexity.ai/favicon.ico";
              definedAliases = [ "@p" ];
            };
          };
          force = true;
        };
        containersForce = true;
        containers = {
          school = {
            id = 4;
            color = "orange";
            icon = "briefcase";
          };
          personal = {
            id = 1;
            color = "blue";
            icon = "chill";
          };
          banking = {
            id = 2;
            color = "red";
            icon = "dollar";
          };
          study = {
            id = 3;
            color = "green";
            icon = "briefcase";
          };
        };
      };
    };
  };
}
