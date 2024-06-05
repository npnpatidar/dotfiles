{ ... }:
{

  services.invidious = {
    enable = true;
    nginx.enable = true;
    domain = "invidious.naresh.world";
    settings.db.user = "invidious";
    settings.db.dbname = "invidious";
  };

}
