{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.librewolf;
  mkOption = enable: value: { inherit enable value; };

  enabled = mkOption true;
  disabled = mkOption false;

  explicit.enabled = enabled true;
  implicit.enabled = enabled false;

  explicit.disabled = disabled false;
  implicit.disabled = disabled true;
in
{
  options.modules.home-manager.librewolf = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
      arkenfox = {
        enable = true;
        version = "master";
      };

      profiles.default = {

        arkenfox = {
          enable = true;

          # 0000: TOPLEVEL
          "0000".enable = true;

          # 0100: STARTUP
          "0100".enable = true;

          # 0200: GEOLOCATION / LANGUAGE / LOCALE
          "0200".enable = true;

          # 0300: QUIETER FOX
          "0300".enable = true;

          # 0600: BLOCK IMPLICIT OUTBOUND [not explicitly asked for - e.g. clicked on]
          "0600".enable = true;

          # 0700: DNS / DoH / PROXY / SOCKS / IPv6
          "0700".enable = true;

          # 0800: LOCATION BAR / SEARCH BAR / SUGGESTIONS / HISTORY / FORMS
          "0800".enable = true;

          # 0900: PASSWORDS
          "0900".enable = true;

          # 1000: DISK AVOIDANCE
          "1000".enable = true;

          # 1200: HTTPS (SSL/TLS / OCSP / CERTS / HPKP)
          "1200".enable = true;

          # 1400: FONTS
          # "1400".enable = true;

          # 1600: HEADERS / REFERERS
          "1600".enable = true;

          # 1700: CONTAINERS
          "1700".enable = true;

          # 2000: PLUGINS / MEDIA / WEBRTC
          "2000".enable = true;

          # 2400: DOM (DOCUMENT OBJECT MODEL)
          "2400".enable = true;

          # 2600: MISCELLANEOUS
          "2600".enable = true;

          # 2700: ETP (ENHANCED TRACKING PROTECTION)
          "2700".enable = true;

          # 2800: SHUTDOWN & SANITIZING
          "2800".enable = true;

          # 4500: RFP (RESIST FINGERPRINTING)
          # Note that currently amiunique.org still detects the fingerprint as unique
          # This is because of user fonts that it detects via JS
          # and media devices being named as audio{in,out}put
          "4500".enable = true;

          # 6000: DON'T TOUCH
          "6000".enable = true;

          # 9000: PERSONAL
          "9000".enable = true;
          #
          # 0400: SAFE BROWSING (SB)
          "0400".enable = true;

          # 5000: OPTIONAL OPSEC
          "5000".enable = false;

          # 5500: OPTIONAL HARDENING
          "5500".enable = false;

          # 7000: DON'T BOTHER
          "7000".enable = false;

          # 8000: DON'T BOTHER: FINGERPRINTING
          "8000".enable = false;

          # resume previous session
          "0100"."0102"."browser.startup.page" = enabled 3;

          "0600"."0610"."browser.send_pings" = implicit.enabled;

          # "0700"."0701"."network.dns.disableIPv6" = implicit.enabled;

          # "0800" = {
          # TODO: use self hosted search engine
          # "0801"."keyword.enabled" = explicit.enabled;

          # "0804" = {
          #   "browser.search.suggest.enabled" = explicit.enabled;
          #   "browser.urlbar.suggest.searches" = explicit.enabled;
          # };
          # };

          # "1400" = {
          # "1402" = {
          #   "layout.css.font-visibility.private" = enabled 1;
          #   "layout.css.font-visibility.standard" = enabled 1;
          #   "layout.css.font-visibility.trackingprotection" = enabled 1;
          # };
          # };

          # "1600"."1601"."network.http.referer.XOriginPolicy".value = 2;

          "2600"."2653"."browser.download.manager.addToRecentDocs" = explicit.enabled;

          "2800" = {
            "2811" = {
              "privacy.clearOnShutdown.downloads" = implicit.enabled;
              "privacy.clearOnShutdown.history" = implicit.enabled;
            };
          };

          # Don't use the built-in password manager; a nixos user is more likely
          # using an external one (you are using one, right?).
          "5000"."5003"."signon.rememberSignons" = implicit.enabled;

          "9000"."9000" = { };
        };

        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          # xdm-browser-monitor-v8
          # bypass-paywalls-clean
          # absolute-enable-right-click
          #  autofill


          skip-redirect
          bitwarden
          darkreader
          floccus
          i-dont-care-about-cookies
          omnivore
          tridactyl
          libredirect
          ublock-origin
          gnome-shell-integration

          #  startpage-privacy-essentials
          # duckduckgo-privacy-essentials
          # no-pdf-download
          # aria2-integration
          # buster-captcha-solver
          # clearurls
          # decentraleyes

        ];

        # ++ (with config.modules.home-manager.firefox-addons;[
        # get-rss-feed-url
        # ]);

        settings = {
          # "browser.startup.homepage" = "https://nixos.org";
          "browser.search.region" = "IN";
          "browser.search.isUS" = false;
          "distribution.searchplugins.defaultLocale" = "en-IN";
          "general.useragent.locale" = "en-IN";
          "browser.bookmarks.showMobileBookmarks" = true;
          "browser.newtabpage.pinned" = [{
            title = "NixOS";
            url = "https://nixos.org";
          }];



          # Performance settings
          "gfx.webrender.all" = true; # Force enable GPU acceleration
          "media.ffmpeg.vaapi.enabled" = true;
          "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes

          # Re-bind ctrl to super (would interfere with tridactyl otherwise)
          "ui.key.accelKey" = 91;

          # Keep the reader button enabled at all times; really don't
          # care if it doesn't work 20% of the time, most websites are
          # crap and unreadable without this
          "reader.parse-on-load.force-enabled" = true;

          # Hide the "sharing indicator", it's especially annoying
          # with tiling WMs on wayland
          "privacy.webrtc.legacyGlobalIndicator" = false;

          # Actual settings
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.contentblocking.category" = "strict";
          "browser.ctrlTab.recentlyUsedOrder" = false;
          "browser.discovery.enabled" = false;
          "browser.laterrun.enabled" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" =
            false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
            false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          # "browser.newtabpage.pinned" = false;
          "browser.protections_panel.infoMessage.seen" = true;
          "browser.quitShortcut.disabled" = true;
          "browser.ssb.enabled" = true;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.suggest.openpage" = false;
          "datareporting.policy.dataSubmissionEnable" = false;
          "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_ever_enabled" = true;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "identity.fxaccounts.enabled" = false;
          "privacy.trackingprotection.socialtracking.enabled" = true;





          "app.normandy.api_url" = "";
          "app.normandy.enabled" = false;
          "app.shield.optoutstudies.enabled" = false;
          "app.update.auto" = false;
          "beacon.enabled" = false;
          "breakpad.reportURL" = "";
          "browser.aboutConfig.showWarning" = false;
          "browser.cache.offline.enable" = false;
          "browser.crashReports.unsubmittedCheck.autoSubmit" = false;
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
          "browser.crashReports.unsubmittedCheck.enabled" = false;
          "browser.disableResetPrompt" = true;
          "browser.newtab.preload" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.newtabpage.enhanced" = false;
          "browser.newtabpage.introShown" = true;
          "browser.safebrowsing.appRepURL" = "";
          "browser.safebrowsing.blockedURIs.enabled" = false;
          "browser.safebrowsing.downloads.enabled" = false;
          "browser.safebrowsing.downloads.remote.enabled" = false;
          "browser.safebrowsing.downloads.remote.url" = "";
          "browser.safebrowsing.enabled" = false;
          "browser.safebrowsing.malware.enabled" = false;
          "browser.safebrowsing.phishing.enabled" = false;
          "browser.selfsupport.url" = "";
          "browser.send_pings" = false;
          "browser.sessionstore.privacy_level" = 2;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.startup.homepage_override.mstone" = "ignore";
          "browser.tabs.crashReporting.sendReport" = false;
          "browser.urlbar.groupLabels.enabled" = false;
          "browser.urlbar.quicksuggest.enabled" = false;
          "browser.urlbar.speculativeConnect.enabled" = false;
          "browser.urlbar.trimURLs" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "device.sensors.ambientLight.enabled" = false;
          "device.sensors.enabled" = false;
          "device.sensors.motion.enabled" = false;
          "device.sensors.orientation.enabled" = false;
          "device.sensors.proximity.enabled" = false;
          "dom.battery.enabled" = false;
          "dom.event.clipboardevents.enabled" = false;
          "dom.webaudio.enabled" = false;
          "experiments.activeExperiment" = false;
          "experiments.enabled" = false;
          "experiments.manifest.uri" = "";
          "experiments.supported" = false;
          "extensions.TemporaryContainers@stoically.whiteList" = "";
          "extensions.getAddons.cache.enabled" = false;
          "extensions.getAddons.showPane" = false;
          "extensions.greasemonkey.stats.optedin" = false;
          "extensions.greasemonkey.stats.url" = "";
          "extensions.pocket.enabled" = false;
          "extensions.shield-recipe-client.api_url" = "";
          "extensions.shield-recipe-client.enabled" = false;
          "extensions.webservice.discoverURL" = "";
          "media.autoplay.default" = 0;
          "media.autoplay.enabled" = true;
          "media.eme.enabled" = false;
          "media.gmp-widevinecdm.enabled" = false;
          "media.navigator.enabled" = false;
          "media.peerconnection.enabled" = false;
          "media.video_stats.enabled" = false;
          "network.allow-experiments" = false;
          "network.captive-portal-service.enabled" = false;
          "network.cookie.cookieBehavior" = 1;
          "network.dns.disablePrefetch" = true;
          "network.dns.disablePrefetchFromHTTPS" = true;
          "network.http.referer.spoofSource" = false;
          "network.http.speculative-parallel-limit" = 0;
          "network.predictor.enable-prefetch" = false;
          "network.predictor.enabled" = false;
          "network.prefetch-next" = false;
          "network.trr.mode" = 5;
          "privacy.donottrackheader.enabled" = true;
          "privacy.donottrackheader.value" = 1;
          "privacy.query_stripping" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.pbmode.enabled" = true;
          "privacy.usercontext.about_newtab_segregation.enabled" = true;
          "security.ssl.disable_session_identifiers" = true;
          "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSite" = false;
          "signon.autofillForms" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.cachedClientID" = "";
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.prompted" = 2;
          "toolkit.telemetry.rejected" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          # "toolkit.telemetry.server" = "";
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.unifiedIsOptIn" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "webgl.disabled" = true;
          "webgl.renderer-string-override" = " ";
          "webgl.vendor-string-override" = " ";





          "accessibility.typeaheadfind" = true;


          "browser.backspace_action" = 2;

          # Dark theme devtools
          "devtools.theme" = "dark";

          # Stop creating ~/Downloads!
          "browser.download.dir" = "~/dl";

          # Show the bookmarks toolbar by default

          # Force using WebRender. Improve performance
          "gfx.webrender.enabled" = true;

          # Enable SVG customization
          "svg.context-properties.content.enabled" = true;

          # Enable extra codecs
          # To prevent fingerprinting, arkenfox users should disable this.
          "image.jxl.enabled" = lib.mkDefault true;

          # Enable multi-pip
          "media.videocontrols.picture-in-picture.allow-multiple" = true;

          # Smooth scroll
          "general.smoothScroll.lines.durationMaxMS" = 125;
          "general.smoothScroll.lines.durationMinMS" = 125;
          "general.smoothScroll.mouseWheel.durationMaxMS" = 200;
          "general.smoothScroll.mouseWheel.durationMinMS" = 100;
          "general.smoothScroll.msdPhysics.enabled" = true;
          "general.smoothScroll.other.durationMaxMS" = 125;
          "general.smoothScroll.other.durationMinMS" = 125;
          "general.smoothScroll.pages.durationMaxMS" = 125;
          "general.smoothScroll.pages.durationMinMS" = 125;

          "mousewheel.min_line_scroll_amount" = 30;
          "mousewheel.system_scroll_override_on_root_content.enabled" = true;
          "mousewheel.system_scroll_override_on_root_content.horizontal.factor" = 175;
          "mousewheel.system_scroll_override_on_root_content.vertical.factor" = 175;
          "toolkit.scrollbox.horizontalScrollDistance" = 6;
          "toolkit.scrollbox.verticalScrollDistance" = 2;

          "startup.homepage_welcome_url" = "";
          "startup.homepage_welcome_url.additional" = "";
          "startup.homepage_override_url" = "";
          "browser.tabs.warnOnClose" = true;
          "browser.tabs.warnOnCloseOtherTabs" = true;
          "browser.tabs.warnOnOpen" = true;
          "browser.warnOnQuitShortcut" = true;
          "full-screen-api.warning.delay" = 0;
          "full-screen-api.warning.timeout" = 0;
          "browser.search.update" = true;
          "extensions.update.enabled" = true;
          "extensions.update.autoUpdateDefault" = true;
          "browser.download.autohideButton" = true;
          # Enable userContent.css and userChrome.css for our theme modules
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "ui.prefersReducedMotion" = 1;
          "ui.systemUsesDarkTheme" = 1;
          "clipboard.autocopy" = true;
          "layout.spellcheckDefault" = 2;
          "browser.tabs.closeWindowWithLastTab" = true;
          "browser.tabs.loadBookmarksInTabs" = true;
          "browser.urlbar.decodeURLsOnCopy" = true;
          # Enable auto scroll
          "general.autoScroll" = true;
          "ui.key.menuAccessKey" = 0;
          "view_source.tab" = true;
          "extensions.screenshots.disabled" = true;
          "reader.parse-on-load.enabled" = true;
          "browser.bookmarks.max_backups" = 2;
          "network.manage-offline-status" = true;
          "xpinstall.signatures.required" = true;


          "privacy.partition.network_state.ocsp_cache" = true;
          # Disable all sorts of telemetry
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "extensions.pocket.api" = "";
          "extensions.pocket.oAuthConsumerKey" = "";
          "extensions.pocket.showHome" = false;
          "extensions.pocket.site" = "";
          # Other
          "browser.shell.defaultBrowserCheckCount" = 1;
        };
      };
    };
  };
}
