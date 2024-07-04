{ config, ... }: {


  services.redis.servers.redis_servers = {
    enable = true;
    port = 6379;
    # user = "n8n";
    # openFirewall = true;
    # requirePass = "ratta";
    # databases = 1;
  };

}
