_: {
  flake.nixosModules.adguardhome = { config, lib, ... }: {
    services = {
      oink.domains = [
        {
          domain = "${config.systemConstants.domain_name}";
          subdomain = "adh";
        }
      ];

      adguardhome = {
        enable = true;
        # Bind the web UI to loopback only (the nginx vhost proxies to it).
        # Do NOT set settings.http for this — the module overrides it with
        # http.address from host/port; setting it here is dead config that
        # would otherwise leave the UI on 0.0.0.0.
        host = "127.0.0.1";
        port = 5380;
        # Fully declarative: the config file is regenerated from Nix on every
        # start, so UI edits are wiped on restart. Note the generated config
        # has no `users` — the UI is unauthenticated at the AdGuard level and
        # relies on tinyauth + loopback binding for access control.
        mutableSettings = false;
        settings = {
          # Local admin account. AdGuard Home has no OIDC/SSO support, so this
          # is the only way to protect the control API against
          # localhost-originated requests (DNS rebinding / localhost CSRF):
          # with zero users, needsAuthentication() is false and every
          # /control/* endpoint is unauthenticated on 127.0.0.1:5380.
          # The bcrypt hash is committed deliberately — it is one-way and the
          # password is a strong random string stored only in the password
          # manager. Never replace this with a weak placeholder hash.
          users = [
            {
              name = "admin";
              password = "$2b$10$.hBxmtbjbKaSVkq1.2UZk.rBK7GWitmeATFesnsOfgazxPeUBVcYO";
            }
          ];
          dns = {
            bootstrap_dns = [
              "9.9.9.9"
              "8.8.8.8"
              "1.1.1.1"
            ];
            # Explicit upstreams instead of relying on the binary default
            # (https://dns10.quad9.net/dns-query alone). load_balance mode
            # queries all of these in parallel.
            upstream_dns = [
              "https://dns10.quad9.net/dns-query"
              "8.8.8.8"
              "1.1.1.1"
            ];
            enable_dnssec = true;
            bind_hosts = [ "0.0.0.0" ];
          };
          user_rules = [
            "@@||cas-bridge.xethub.hf.co^"
            "@@||hf.co^"
            "@@||huggingface.co^"
            "@@||controlplane.tailscale.com^$important"
            "||speechs3proto2-pa.googleapis.com^"
          ];
          filters =
            let
              # Researched set (2026-07): HaGeZi lists are compiled FROM most of
              # the old lists — OISD Big, Phishing Army and URLHaus are sources
              # in hagezi/dns-blocklists/sources.md, and native trackers (incl.
              # OPPO/Realme) are inside Ultimate — so running them alongside
              # was pure duplication (~3.6M rules before, ~1.0M now).
              #
              # tif.mini replaces tif full, which the README marks as "too big"
              # for AdGuard (~2.2M entries; the old config's main RAM consumer).
              # NRD was dropped: the old nrd35-29 URL is dead (HTTP 403) and the
              # new hagezi/nrd repo ships multi-million-entry weekly windows
              # (high false positives). adblock format is the one recommended
              # for AdGuard Home.
              urls = [
                {
                  name = "HaGeZi's Ultimate Blocklist";
                  url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/ultimate.txt";
                }
                {
                  name = "HaGeZi's Threat Intelligence Feeds (mini)";
                  url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.mini.txt";
                }
                {
                  name = "HaGeZi's Encrypted DNS/VPN/TOR/Proxy Bypass";
                  url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/doh-vpn-proxy-bypass.txt";
                }
                {
                  name = "HaGeZi's NSFW Blocklist";
                  url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/nsfw.txt";
                }
                {
                  name = "HaGeZi's Gambling DNS Blocklist";
                  url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/gambling.txt";
                }
                {
                  name = "HaGeZi's URL Shortener Blocklist";
                  url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/urlshortener.txt";
                }
              ];
              buildList = id: url: {
                enabled = true;
                inherit id;
                inherit (url) name;
                inherit (url) url;
              };
            in
            lib.imap1 buildList urls;
          filtering = {
            protection_enabled = true;
            filtering_enabled = true;
            parental_enabled = true;
            # Keep safe browsing consistent with parental (both block hosts are
            # configured below). Both send hash-prefix lookups to AdGuard's
            # API — a privacy tradeoff vs. pure local blocklists.
            safebrowsing_enabled = true;
            safe_search.enabled = false;
            parental_block_host = "family-block.dns.adguard.com";
            safebrowsing_block_host = "standard-block.dns.adguard.com";
            blocked_services.ids = [
              "4chan"
              "500px"
              "9gag"
              "amino"
              "bluesky"
              "clubhouse"
              "discord"
              "douban"
              "facebook"
              "kook"
              "line"
              "linkedin"
              "mail_ru"
              "mastodon"
              "odysee"
              "ok"
              "onlyfans"
              "snapchat"
              "tiktok"
              "tumblr"
              "vk"
              "zhihu"
              "activision_blizzard"
              "battle_net"
              "blizzard_entertainment"
              "electronic_arts"
              "epic_games"
              "gog"
              "leagueoflegends"
              "minecraft"
              "nintendo"
              "origin"
              "playstation"
              "riot_games"
              "roblox"
              "rockstar_games"
              "steam"
              "ubisoft"
              "valorant"
              "wargaming"
              "xboxlive"
              "aliexpress"
              "coolapk"
              "ebay"
              "lazada"
              "mercado_libre"
              "shein"
              "shopee"
              "temu"
              "xiaohongshu"
              "amazon_streaming"
              "apple_streaming"
              "bigo_live"
              "bilibili"
              "canais_globo"
              "claro"
              "crunchyroll"
              "dailymotion"
              "deezer"
              "directvgo"
              "discoveryplus"
              "disneyplus"
              "espn"
              "fifa"
              "globoplay"
              "hbomax"
              "hulu"
              "iheartradio"
              "iqiyi"
              "lionsgateplus"
              "looke"
              "nebula"
              "netflix"
              "paramountplus"
              "peacock_tv"
              "plex"
              "pluto_tv"
              "qq"
              "rakuten_viki"
              "samsung_tv_plus"
              "soundcloud"
              "spotify"
              "spotify_video"
              "tidal"
              "twitch"
              "vimeo"
              "voot"
              "weibo"
              "yy"
              "betano"
              "betfair"
              "betway"
              "blaze"
              "kakaotalk"
              "kik"
              "olvid"
              "skype"
              "slack"
              "viber"
              "wechat"
              "plenty_of_fish"
              "tinder"
              "wizz"
            ];
          };
          querylog = {
            enabled = true;
            ignored_enabled = true;
            ignored = [
              "||filen.io"
              "||filen.net"
              "||filen-1.net"
              "||filen-2.net"
              "||filen-3.net"
              "||filen-4.net"
              "||filen-5.net"
              "||syncthing.net"
              "||${config.systemConstants.domain_name}"
              "maps.rspamd.com"
              "github.com"
            ];
          };
          statistics = {
            enabled = true;
            ignored_enabled = true;
            ignored = [
              "||filen.io"
              "||filen.net"
              "||filen-1.net"
              "||filen-2.net"
              "||filen-3.net"
              "||filen-4.net"
              "||filen-5.net"
              "||syncthing.net"
              "||${config.systemConstants.domain_name}"
              "maps.rspamd.com"
              "github.com"
            ];
          };
          clients.persistent = [
            {
              name = "3";
              ids = [ "100.64.0.3" ];
              use_global_settings = true;
              use_global_blocked_services = true;
            }
            {
              name = "2";
              ids = [ "100.64.0.2" ];
              use_global_settings = true;
              use_global_blocked_services = true;
            }
            {
              name = "1";
              ids = [ "100.64.0.1" ];
              use_global_settings = true;
              use_global_blocked_services = true;
            }
            {
              name = "4";
              ids = [ "100.64.0.4" ];
              use_global_settings = true;
              use_global_blocked_services = true;
            }
          ];
        };
        allowDHCP = false;
      };

      nginx.virtualHosts."adh.${config.systemConstants.domain_name}" = {
        enableACME = true;
        forceSSL = true;
        enableTinyauth = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
        };
      };

      # DNS-over-TLS (Android "Private DNS") on TCP 853. Terminates TLS with
      # the existing adh.<domain> Let's Encrypt cert and forwards to AGH's
      # plain DNS on 127.0.0.1:53. Clients appear as 127.0.0.1 to AGH (global
      # settings apply, per-client overrides don't) and all DoT users share
      # the default 20 rps ratelimit — fine for the phone. Requires TCP 853
      # to be opened in the Oracle Cloud VCN security list/NSG (done in the
      # OCI console; the OS firewall rule lives in networking-alma.nix).
      nginx.streamConfig = ''
        server {
          listen 853 ssl;
          ssl_certificate /var/lib/acme/adh.${config.systemConstants.domain_name}/fullchain.pem;
          ssl_certificate_key /var/lib/acme/adh.${config.systemConstants.domain_name}/key.pem;
          ssl_protocols TLSv1.2 TLSv1.3;
          proxy_pass 127.0.0.1:53;
        }
      '';
    };
  };
}
