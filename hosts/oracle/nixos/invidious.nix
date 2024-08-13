{ config, ... }:
{

  services.invidious = {
    enable = true;
    nginx.enable = true;
    port = 3009;
    domain = "invidious.${config.globals.domain_name}";
    settings = {
      db.user = "invidious";
      db.dbname = "invidious";
      statistics_enabled = false;
      registration_enabled = false;
      login_enabled = true;
      captcha_enabled = false;
      admins = [ "naresh" ];

      # use_pubsub_feeds = false;
      # channel_refresh_interval = "15m";
      dark_mode = "dark";
      autoplay = false;
      default_user_preferences = {
        locale = "en-IN";
        region = "IN";
        captions = [ "English" "Englich (auto-generated)" ];
        feed_menu = [ "Subscriptions" "Playlists" ];
        default_home = "Subscriptions";
        player_style = "youtube";
        comments = [ "youtube" "reddit" ];
        quality = "dash";
        thin_mode = false;
      };
    };
  };

}
