_: {
  flake.nixosModules.databases = { pkgs, ... }: {
    services.redis.servers.redis_servers = {
      enable = true;
      port = 6379;
      bind = "0.0.0.0";
      requirePass = "redis-Password";
    };

    services.postgresql = {
      enable = true;
      settings.port = 5432;
      extensions = with pkgs.postgresql_16.pkgs; [ pgvector ];
      package = pkgs.postgresql_16;
      enableTCPIP = true;
      ensureUsers = [
        {
          name = "n8n";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [
        "n8n"
      ];
      initialScript = pkgs.writeText "init-sql-script" ''
        alter user n8n with password 'n8n-Password';
      '';
      authentication = ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all 10.0.0.0/24 trust
      '';
    };
  };
}
