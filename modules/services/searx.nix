_: {
  flake.nixosModules.searx = { config, pkgs, ... }: {
    sops.secrets.searx_environment_file = {
      sopsFile = ../../secrets/alma.yaml;
    };

    services = {
      oink.domains = [
        {
          domain = "${config.systemConstants.domain_name}";
          subdomain = "searx";
        }
      ];

      searx = {
        enable = true;
        package = pkgs.searxng;
        environmentFile = config.sops.secrets.searx_environment_file.path;
        settings = {
          server = {
            port = 8056;
            bind_address = "127.0.0.1";
            public_instance = false;
            secret_key = "$SEARX_SECRET_KEY";
            infinite_scroll = true;
          };
          general = {
            debug = false;
            instance_name = "SearXNG";
            privacypolicy_url = false;
            donation_url = false;
            contact_url = false;
            enable_metrics = false;
          };
          ui = {
            default_theme = "simple";
            theme_args = {
              simple_style = "dark";
            };
          };
          search = {
            autocomplete = "startpage";
            safe_search = 0;
            # "all" avoids regional bias (en-IN surfaced Indian LinkedIn/college
            # noise in google cse results); agent queries want neutral results.
            default_lang = "all";
            formats = [
              "html"
              "json"
            ];
          };
          # Fail fast on dead/captcha'd engines instead of stalling every query.
          outgoing = {
            request_timeout = 2.0;
            max_request_timeout = 5.0;
          };
          # NOTE: searxng merges this list with its built-in engine defaults, so
          # engines not listed here stay at their default state (mostly enabled).
          # Junk engines (torrents/social) are therefore disabled explicitly.
          engines = [
            # --- core general web ---
            # google cse is the best relevance here (bing fails on niche/coding
            # queries and tops results with weak matches), so weight it highest.
            {
              name = "google cse";
              disabled = false;
              weight = 2.0;
            }
            {
              name = "bing";
              disabled = false;
              weight = 1.0;
            }
            {
              name = "brave";
              weight = 1.5;
            }
            {
              name = "mojeek";
              disabled = false;
              weight = 1.0;
            }
            # captcha-suspended; disable to avoid multi-second stalls
            {
              name = "duckduckgo";
              disabled = true;
            }
            {
              name = "startpage";
              disabled = true;
            }
            {
              name = "startpage news";
              disabled = true;
            }
            {
              name = "startpage images";
              disabled = true;
            }
            # --- reference (low weight so ambiguity doesn't pollute) ---
            {
              name = "wikipedia";
              shortcut = "w";
              base_url = "https://wikipedia.org/";
              weight = 0.5;
            }
            {
              name = "wikidata";
              weight = 0.5;
            }
            {
              name = "wolframalpha";
              disabled = false;
              weight = 0.5;
            }
            # --- it / coding (queried via categories=it) ---
            {
              name = "archwiki";
              engine = "archlinux";
              shortcut = "aw";
            }
            {
              name = "nixos wiki";
              disabled = false;
            }
            {
              name = "github";
              engine = "github";
              shortcut = "gh";
            }
            {
              name = "gitlab";
              disabled = false;
            }
            {
              name = "codeberg";
              disabled = false;
            }
            {
              name = "stackoverflow";
              disabled = false;
            }
            {
              name = "mdn";
              disabled = false;
            }
            {
              name = "mankier";
              disabled = false;
            }
            {
              name = "docker hub";
              disabled = false;
            }
            {
              name = "huggingface";
              disabled = false;
            }
            {
              name = "pypi";
              disabled = false;
            }
            {
              name = "npm";
              disabled = false;
            }
            {
              name = "crates.io";
              disabled = false;
            }
            {
              name = "packagist";
              disabled = false;
            }
            {
              name = "lib.rs";
              disabled = false;
            }
            {
              name = "hackernews";
              disabled = false;
            }
            {
              name = "lobste.rs";
              disabled = false;
            }
            {
              name = "openalex";
              disabled = false;
            }
            # --- explicitly disable junk ---
            {
              name = "1337x";
              disabled = true;
            }
            {
              name = "piratebay";
              disabled = true;
            }
            {
              name = "kickass";
              disabled = true;
            }
            {
              name = "solidtorrents";
              disabled = true;
            }
            {
              name = "bt4g";
              disabled = true;
            }
            {
              name = "btdigg";
              disabled = true;
            }
            {
              name = "nyaa";
              disabled = true;
            }
            {
              name = "tokyotoshokan";
              disabled = true;
            }
            {
              name = "library genesis";
              disabled = true;
            }
            {
              name = "lemmy communities";
              disabled = true;
            }
            {
              name = "lemmy users";
              disabled = true;
            }
            {
              name = "lemmy posts";
              disabled = true;
            }
            {
              name = "lemmy comments";
              disabled = true;
            }
            {
              name = "mastodon users";
              disabled = true;
            }
            {
              name = "mastodon hashtags";
              disabled = true;
            }
            {
              name = "tootfinder";
              disabled = true;
            }
            {
              name = "qwant";
              disabled = true;
            }
          ];
        };
      };

      nginx.virtualHosts."searx.${config.systemConstants.domain_name}" = {
        enableACME = true;
        forceSSL = true;
        enableTinyauth = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8056";
        };
      };
    };
  };
}
