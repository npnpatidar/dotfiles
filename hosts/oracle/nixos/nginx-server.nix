{ ... }: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@whatisleft.anonaddy.com";
  };

  age.secrets.htpasswdstandard = {
    file = ../../../secrets/htpasswdstandard.age;
    mode = "770";
    owner = "nginx";
    group = "nginx";
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;

    # virtualHosts."test.naresh.world" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:8384";
    #   };
    # };
  };
}
