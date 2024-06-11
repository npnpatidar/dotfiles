{ config, pkgs, ... }: {
  virtualisation.oci-containers.containers."stirling-pdf" = {
    image = "frooodle/s-pdf:latest";
    ports = [ "8088:8080" ];
    volumes = [
      "/var/lib/stirling-pdf/customFiles:/customFiles/"
      "/var/lib/stirling-pdf/extraConfigs:/configs"
      "/var/lib/stirling-pdf/trainingData:/usr/share/tesseract-ocr/4.00/tessdata"
    ];
  };
  age.secrets.vscode_htpassword = {
    file = ../../../secrets/vscode_htpassword.age;
    mode = "770";
    owner = "nginx";
    group = "nginx";
  };
  services.nginx = {
    virtualHosts."stirling.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = config.age.secrets.vscode_htpassword.path;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8088";
      };
    };
  };
}
