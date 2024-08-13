{ config, pkgs, ... }: {
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    settings = {
      server = {
        port = 8056;
        bind_address = "0.0.0.0";
        public_instance = false;
        secret_key = "@SEARXNG_SECRET@";
        infinite_scroll = true;
      };
      general = {
        debug = false;
        instance_name = "SearXNG";
        privacypolicy_url = false;
        donation_url = false;
        contact_url = false;
        enable_metrics = true;
      };
      ui = {
        default_theme = "simple";
        theme_args = {
          simple_style = "dark";
        };
      };
      search = {
        autocomplete = "google";
        safe_search = 0;
        default_lang = "en-IN";
      };
      engines =
        [
          {
            name = "bing";
            engine = "bing";
            disabled = false;
          }
          {
            name = "1337x";
            disabled = false;
          }
          {
            name = "qwant";
            disabled = true;
          }
          {
            name = "archwiki";
            engine = "archlinux";
            shortcut = "aw";
          }
          {
            name = "wikipedia";
            engine = "wikipedia";
            shortcut = "w";
            base_url = "https://wikipedia.org/";
          }
          {
            name = "duckduckgo";
            engine = "duckduckgo";
            shortcut = "ddg";
          }
          {
            name = "github";
            engine = "github";
            shortcut = "gh";
          }
          {
            name = "google";
            engine = "google";
            shortcut = "g";
            use_mobile_ui = false;
          }

        ];
    };
  };

  services.nginx = {
    virtualHosts."searx.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8056";
      };
    };
  };
}
