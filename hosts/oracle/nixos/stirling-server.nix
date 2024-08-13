{ config, pkgs, ... }:
let
  rootPath = "/var/lib/stirling-pdf";
  customFilesPath = "${rootPath}/customFiles";
  extraConfigsPath = "${rootPath}/extraConfigs";
  trainingDataPath = "${rootPath}/trainingData";
in
{
  systemd.services."createCouchDBFolder" = {
    script = ''
      mkdir -p ${customFilesPath}
      mkdir -p ${extraConfigsPath}
      mkdir -p ${trainingDataPath}
    '';
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-stirling-pdf.service" ];
    serviceConfig.Type = "oneshot";
  };

  virtualisation.oci-containers.containers."stirling-pdf" = {
    image = "frooodle/s-pdf:latest";
    ports = [ "8088:8080" ];
    volumes = [
      "${customFilesPath}:/customFiles/"
      "${extraConfigsPath}:/configs"
      "${trainingDataPath}:/usr/share/tesseract-ocr/4.00/tessdata"
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
