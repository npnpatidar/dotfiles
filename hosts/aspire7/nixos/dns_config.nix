{ config, pkgs, ... }: {


  # Adguard DNS 
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      server_names = [ "adguard-dns-doh" ];
      # server_names = [ "nextdns-ipv6" ];
    };
  };


  services.resolved = {
    enable = true;
    extraConfig = ''
            DNS=45.90.28.0#65e6f3.dns.nextdns.io
            DNS=2a07:a8c0::#65e6f3.dns.nextdns.io
            DNS=45.90.30.0#65e6f3.dns.nextdns.io
            DNS=2a07:a8c1::#65e6f3.dns.nextdns.io
            DNSOverTLS=yes
            '';
  };
}
