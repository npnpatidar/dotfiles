_: {
  flake.homeModules.zen-browser =
    {
      config,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.zen-browser.homeModules.beta ];
      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = false;
        profiles.default = {
          id = 0;
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            bitwarden
            floccus
            skip-redirect
            absolute-enable-right-click
            tridactyl
            karakeep
            buster-captcha-solver
            clearurls
            imagus
            multi-account-containers
            ublock-origin
            print-to-pdf-document
            istilldontcareaboutcookies
            web-clipper-obsidian
            enhanced-github
          ];
          extensions.force = true;
          settings = {
            # --- librewolf.cfg parity (user overrides kept where set) ---
            # PRIVACY: strict content blocking, partitioning, no disk cache, query stripping
            "browser.contentblocking.category" = "strict";
            "network.cookie.cookieBehavior.optInPartitioning" = true;
            "network.cookie.cookieBehavior.optInPartitioning.pbmode" = true;
            # librewolf.cfg ISOLATION: always partition 3rd-party non-cookie storage (localStorage etc.)
            "privacy.partition.always_partition_third_party_non_cookie_storage" = true;
            "privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage" = false;
            # arkenfox 7016: bounce/redirect tracking protection
            "privacy.bounceTrackingProtection.mode" = 1;
            "browser.cache.disk.enable" = false;
            "browser.privatebrowsing.forceMediaMemoryCache" = true;
            "media.memory_cache_max_size" = 65536;
            "browser.shell.shortcutFavicons" = false;
            "browser.helperApps.deleteTempFileOnExit" = true;
            "privacy.history.custom" = true;
            "browser.formfill.enable" = false;
            "browser.sessionstore.privacy_level" = 2;
            "privacy.query_stripping.enabled" = true;
            "privacy.query_stripping.pbmode.enabled" = true;
            "privacy.query_stripping.strip_list" =
              "__hsfp __hssc __hstc __s _bhlid _branch_match_id _branch_referrer _gl _hsenc _openstat at_recipient_id at_recipient_list bbeml bsft_clkid bsft_uid dclid et_rid fb_action_ids fb_comment_id fbclid gclid guce_referrer guce_referrer_sig hsCtaTracking irclickid mc_eid ml_subscriber ml_subscriber_hash msclkid mtm_cid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id pk_cid rb_clickid s_cid sc_customer sc_eh sc_uid sfmc_activityid sfmc_id sms_click sms_source sms_uph srsltid ss_email_id syclid ttclid twclid unicorn_click_id vero_conv vero_id vgo_ee wbraid wickedid yclid ymclid ysclid";
            "privacy.query_stripping.allow_list" = "urldefense.com";
            "cookiebanners.service.mode" = 1;
            "cookiebanners.service.mode.privateBrowsing" = 1;
            "browser.dom.window.dump.enabled" = false;
            "devtools.console.stdout.chrome" = false;
            # librewolf.cfg SANITIZING: clear cache+formdata on shutdown, keep history/downloads/cookies
            "privacy.sanitize.sanitizeOnShutdown" = true;
            "privacy.sanitize.timeSpan" = 0;
            "privacy.clearOnShutdown_v2.cache" = true;
            "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;
            "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
            "privacy.clearOnShutdown_v2.downloads" = false;
            "privacy.clearOnShutdown_v2.formdata" = true;
            "privacy.clearOnShutdown.offlineApps" = true;
            # NETWORKING: HTTPS-only, referer trimming, no prefetch/speculative, DoH off
            "network.auth.subresource-http-auth-allow" = 1;
            "dom.security.https_only_mode.upgrade_local" = true;
            "dom.security.https_only_mode" = true; # librewolf.cfg: HTTPS-only in ALL windows
            "dom.security.https_only_mode_send_http_background_request" = false; # arkenfox 1246
            "network.http.referer.XOriginTrimmingPolicy" = 2;
            "network.dns.disablePrefetch" = true;
            "network.dns.disablePrefetchFromHTTPS" = true;
            "network.dns.disableIPv6" = true;
            # librewolf.cfg DNS: skip the DoH probe connection; disable the network predictor
            "network.trr.confirmationNS" = "skip";
            "network.predictor.enabled" = false;
            "network.trr.mode" = 5;
            "network.prefetch-next" = false;
            "network.http.speculative-parallel-limit" = 0;
            "browser.places.speculativeConnect.enabled" = false;
            "browser.urlbar.speculativeConnect.enabled" = false;
            "network.gio.supported-protocols" = "";
            "network.file.disable_unc_paths" = true;
            "network.proxy.socks_remote_dns" = true;
            "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
            # librewolf.cfg WEBRTC: single interface for ICE candidates (mDNS still hides local IP)
            "media.peerconnection.ice.default_address_only" = true;
            "security.csp.reporting.enabled" = false;
            # FINGERPRINTING: RFP extras, GPC, WebGPU off
            "privacy.resistFingerprinting" = true;
            "privacy.resistFingerprinting.letterboxing" = false;
            "privacy.resistFingerprinting.block_mozAddonManager" = true;
            # arkenfox 4506: suppress RFP's "spoof language to English" prompt
            "privacy.spoof_english" = 1;
            # [zen] keep letterboxing OFF: buggy in Zen (#7307/#6974/#9217) - already false above
            "privacy.window.maxInnerWidth" = 1600;
            "privacy.window.maxInnerHeight" = 900;
            "privacy.globalprivacycontrol.enabled" = true;
            "privacy.globalprivacycontrol.pbmode.enabled" = true;
            "privacy.globalprivacycontrol.functionality.enabled" = true;
            "dom.webgpu.enabled" = false;
            "pdfjs.enableWebGPU" = false;
            # SECURITY: pinning, CRLite, OCSP off, no 0-RTT, punycode, safe browsing off
            "security.cert_pinning.enforcement_level" = 2;
            "security.ssl.require_safe_negotiation" = true;
            "security.ssl.treat_unsafe_negotiation_as_broken" = true;
            # librewolf.cfg TLS: advanced cert error pages, no deprecated TLS downgrades
            "browser.xul.error_pages.expert_bad_cert" = true;
            "security.tls.version.enable-deprecated" = false;
            "security.pki.crlite_mode" = 2;
            "security.remote_settings.crlite_filters.enabled" = true; # librewolf.cfg: keep CRLite filter updates on
            "security.OCSP.enabled" = 0;
            "security.OCSP.require" = false;
            "security.certerrors.mitm.auto_enable_enterprise_roots" = false;
            "security.enterprise_roots.enabled" = false;
            "security.tls.enable_0rtt_data" = false;
            "network.http.http3.enable_0rtt" = false;
            "permissions.manager.defaultsUrl" = "";
            "permissions.delegation.enabled" = false; # librewolf.cfg: permission prompts show real origin
            "webchannel.allowObject.urlWhitelist" = ""; # librewolf.cfg: remove web channel whitelist
            # arkenfox 2630: block DLP content-analysis agents
            "browser.contentanalysis.enabled" = false;
            "browser.contentanalysis.default_result" = 0;
            "network.IDN_show_punycode" = true;
            "pdfjs.enableScripting" = false;
            "dom.webserial.enabled" = false;
            "dom.webserial.gated" = true;
            "browser.safebrowsing.malware.enabled" = false;
            "browser.safebrowsing.phishing.enabled" = false;
            "browser.safebrowsing.blockedURIs.enabled" = false;
            "browser.safebrowsing.provider.google4.gethashURL" = "";
            "browser.safebrowsing.provider.google4.updateURL" = "";
            "browser.safebrowsing.provider.google.gethashURL" = "";
            "browser.safebrowsing.provider.google.updateURL" = "";
            "browser.safebrowsing.downloads.enabled" = false;
            "browser.safebrowsing.downloads.remote.enabled" = false;
            "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = false;
            "browser.safebrowsing.downloads.remote.block_uncommon" = false;
            "browser.safebrowsing.downloads.remote.url" = "";
            "browser.safebrowsing.provider.google4.dataSharingURL" = "";
            # REGION: beacondb geolocation, no Mozilla region lookups
            "geo.provider.network.url" = "https://api.beacondb.net/v1/geolocate";
            "geo.provider.use_geoclue" = false;
            "browser.region.network.url" = "";
            "browser.region.update.enabled" = false;
            # BEHAVIOR: no search suggestions/quick suggest, ask for downloads, no ML/AI
            "browser.urlbar.suggest.searches" = false;
            "browser.search.suggest.enabled" = false;
            "browser.search.update" = false;
            "browser.search.serpEventTelemetryCategorization.enabled" = false;
            "browser.urlbar.quicksuggest.enabled" = false;
            "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;
            "browser.urlbar.suggest.weather" = false;
            "browser.urlbar.addons.featureGate" = false;
            "browser.urlbar.mdn.featureGate" = false;
            "browser.urlbar.trending.featureGate" = false;
            "browser.urlbar.weather.featureGate" = false;
            "browser.urlbar.importantDates.featureGate" = false;
            "browser.urlbar.market.featureGate" = false;
            "browser.urlbar.yelp.featureGate" = false;
            "browser.urlbar.yelpRealtime.featureGate" = false;
            "browser.urlbar.amp.featureGate" = false;
            "browser.urlbar.wikipedia.featureGate" = false;
            # arkenfox 9004: show URLs, not search terms, in the urlbar
            "browser.urlbar.showSearchTerms.enabled" = false;
            "browser.download.useDownloadDir" = false;
            "browser.download.manager.addToRecentDocs" = false;
            "browser.download.alwaysOpenPanel" = false;
            # arkenfox 2603/2654: downloads via temp dir + always ask for new mime types
            "browser.download.start_downloads_in_tmp_dir" = true;
            "browser.download.always_ask_before_handling_new_types" = true;
            "media.autoplay.default" = 5;
            # librewolf.cfg DRM: disable widevine/EME (breaks DRM streaming: Netflix, Prime, Hotstar)
            "media.eme.enabled" = false;
            "browser.eme.ui.enabled" = false;
            "dom.disable_window_move_resize" = true;
            # librewolf.cfg POP-UPS: links targeting new windows open as tabs instead
            "browser.link.open_newwindow" = 3;
            "browser.link.open_newwindow.restriction" = 0;
            # librewolf.cfg MOUSE: no middle-click clipboard search from the new-tab button
            "browser.tabs.searchclipboardfor.middleclick" = false;
            "browser.ml.enable" = false;
            "browser.ml.chat.menu" = false;
            "browser.ml.linkPreview.supportedLocales" = "null";
            "extensions.ui.mlmodel.hidden" = true;
            "browser.tabs.groups.smart.enabled" = false;
            "browser.ai.control.default" = "blocked";
            "extensions.webextensions.restrictedDomains" = "";
            "signon.rememberSignons" = false;
            "signon.autofillForms" = false;
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "signon.formlessCapture.enabled" = false;
            "privacy.antitracking.isolateContentScriptResources" = true;
            "devtools.debugger.remote-enabled" = false;
            "media.gmp-manager.url" = "data:text/plain,";
            "media.gmp-provider.enabled" = false;
            "media.gmp-gmpopenh264.enabled" = false;
            "extensions.webcompat-reporter.enabled" = false;
            # UI: no onboarding/WNP, no sponsored content, no ads in about pages
            "browser.startup.homepage_override.mstone" = "ignore";
            "browser.uitour.enabled" = false;
            "browser.uitour.url" = "";
            # librewolf.cfg UI: no what's-new panel, no top stories/sponsored content on new tab
            "browser.messaging-system.whatsNewPanel.enabled" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
            "browser.newtabpage.activity-stream.default.sites" = "";
            "browser.preferences.moreFromMozilla" = false;
            "browser.contentblocking.report.vpn.enabled" = false;
            # arkenfox 9002: no "recommend as you browse" prompts
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 999;
            "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
            "startup.homepage_welcome_url" = "about:blank";
            "startup.homepage_welcome_url.additional" = "";
            "browser.newtabpage.activity-stream.feeds.weatherfeed" = false;
            "browser.contentblocking.report.lockwise.enabled" = false;
            "browser.contentblocking.report.hide_vpn_banner" = true;
            "browser.contentblocking.report.show_mobile_app" = false;
            "browser.vpn_promo.enabled" = false;
            "browser.promo.focus.enabled" = false;
            "extensions.htmlaboutaddons.recommendations.enabled" = false;
            "extensions.getAddons.showPane" = false;
            "browser.topsites.useRemoteSetting" = false;
            "browser.topsites.contile.enabled" = false;
            "browser.aboutConfig.showWarning" = false;
            "identity.fxaccounts.toolbar.pxiToolbarEnabled" = false;
            "browser.urlbar.trustPanel.breachAlerts.featureGate" = false;
            "browser.urlbar.trustPanel.breachAlerts" = false;
            "browser.preferences.experimental.hidden" = true;
            "app.update.auto" = false;
            # TELEMETRY / STUDIES: everything librewolf kills, plus the compile-out equivalents
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.server" = "data:,";
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.cachedClientID" = "";
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            "toolkit.coverage.opt-out" = true;
            "toolkit.coverage.enabled" = false;
            "toolkit.coverage.endpoint.base" = "";
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "datareporting.usage.uploadEnabled" = false;
            "app.normandy.enabled" = false;
            "app.normandy.api_url" = "";
            "app.shield.optoutstudies.enabled" = false;
            "browser.discovery.enabled" = false;
            "browser.tabs.crashReporting.sendReport" = false;
            "breakpad.reportURL" = "";
            "browser.crashReports.onDemand" = false;
            "browser.crashReports.requestedNeverShowAgain" = true;
            "network.connectivity-service.enabled" = false;
            "network.captive-portal-service.enabled" = false;
            "captivedetect.canonicalURL" = "";
            "dom.private-attribution.submission.enabled" = false;
            "extensions.gleanPingAddons.daily.interval" = 2147483647;
            "extensions.gleanPingAddons.updated.delay" = 2147483647;
            "extensions.gleanPingAddons.updated.idleTimeout" = 2147483647;
            "extensions.gleanPingAddons.updated.testing" = false;
            "nimbus.rollouts.enabled" = false;
            "experiments.activeExperiment" = false;
            "experiments.enabled" = false;
            "experiments.supported" = false;
            "network.allow-experiments" = false;
            "browser.ping-centre.telemetry" = false;
            "toolkit.telemetry.previousBuildID" = "";
            "toolkit.telemetry.server_owner" = "";
            "toolkit.crashreporter.infoURL" = "";
            "security.protectionspopup.recordEventTelemetry" = false;
            "browser.discovery.containers.enabled" = false;
            "browser.discovery.sites" = "";
            # librewolf.cfg EXTENSIONS: install scope profile+application, no system addon auto-updates,
            # no AMO metadata fetching, prompt for 3rd-party installs
            "extensions.enabledScopes" = 5;
            "extensions.postDownloadThirdPartyPrompt" = false;
            "extensions.systemAddon.update.enabled" = false;
            "extensions.systemAddon.update.url" = "";
            "extensions.getAddons.cache.enabled" = false;
            # pre-existing profile prefs
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "extensions.autoDisableScopes" = 0;
            "extensions.update.enabled" = false;
            "xpinstall.signatures.required" = false;
            "browser.quitShortcut.disabled" = true;
            "browser.uidensity" = 0;
            "browser.startup.page" = 3;
            "browser.warnOnQuitShortcut" = false;
            "identity.fxaccounts.enabled" = true;
            "webgl.disabled" = true;
            "media.peerconnection.ice.no_host" = false;
            "browser.sessionstore.resume_from_crash" = false;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.downloads" = false;
            "privacy.clearOnShutdown.cookies" = false;
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
            "browser.display.use_document_fonts" = true;
            "pdfjs.disabled" = true;
            "media.videocontrols.picture-in-picture.enabled" = true;
            "widget.non-native-theme.enabled" = false;
            "browser.newtabpage.enabled" = false;
            "browser.startup.homepage" = "about:blank";
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
          };
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
