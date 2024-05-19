{ config, ... }: {
  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless_password.path;
    settings = {
      PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = false;
      PAPERLESS_OCR_LANGUAGE = "hin+eng+san";
      PAPERLESS_OCR_SKIP_ARCHIVE_FILE = "always";
      PAPERLESS_TIME_ZONE = config.time.timeZone;
      PAPERLESS_THREADS_PER_WORKER = 4;
    };
  };
  services.nginx = {
    virtualHosts."paperless.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:28981";
      };
      extraConfig = ''
        client_max_body_size 0;
      '';
    };
  };
}
