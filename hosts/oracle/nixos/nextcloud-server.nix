{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs;[ ffmpeg_7-headless exiftool ];

  age.secrets.nextcloud_admin_password = {
    file = ../../../secrets/nextcloud_admin_password.age;
    mode = "770";
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.nextcloud =
    let
      passwords = pkgs.fetchNextcloudApp {
        url = "https://git.mdns.eu/api/v4/projects/45/packages/generic/passwords/2024.2.0/passwords.tar.gz";
        sha256 = "0s5z6pxkcwmhlbzy9s2g0s05n1iqjmxr2jqxz7ayklin9kcgr3h7";
        license = "gpl3";
      };
      integration_github = pkgs.fetchNextcloudApp {
        url = "https://github.com/nextcloud-releases/integration_github/releases/download/v2.0.6/integration_github-v2.0.6.tar.gz";
        sha256 = "0rjdlsalayb21nmh3j5bl42dcbavxka2r5g9csagz7vc9dl0qrw6";
        license = "gpl3";
      };
      news = pkgs.fetchNextcloudApp {
        appName = "news";
        appVersion = "25.0.0-alpha5";
        url = "https://github.com/nextcloud/news/releases/download/25.0.0-alpha5/news.tar.gz";
        sha256 = "sha256-BbGzrOBDshZfiDhKUMiTXGnI7767hpCGsujMbPqmJyg=";
        license = "agpl3Plus";
      };
      passMan = pkgs.fetchNextcloudApp {
        appName = "Passman";
        appVersion = "2.4.9";
        url = "https://github.com/nextcloud/passman/archive/refs/tags/2.4.9.tar.gz";
        sha256 = "sha256-BbGzrOBDshZfiDhKUMiTXGnI7767hpCGsujMbPqmJyg=";
        license = "agpl3Plus";
      };
    in
    {
      enable = true;
      package = pkgs.nextcloud29;
      hostName = "nextcloud.naresh.world";
      # extraApps = with pkgs.nextcloud28Packages.apps; {
      #   inherit passMan passwords mail contacts news bookmarks calendar notes onlyoffice tasks memories previewgenerator twofactor_webauthn groupfolders end_to_end_encryption integration_github;
      # };
      extraAppsEnable = true;
      https = true;
      config = {
        adminpassFile = config.age.secrets."nextcloud_admin_password".path;
      };
    };
  services.nginx = {
    virtualHosts."nextcloud.naresh.world" = {
      forceSSL = true;
      enableACME = true;
    };
  };
}
