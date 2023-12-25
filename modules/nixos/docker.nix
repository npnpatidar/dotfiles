{ config, pkgs, lib, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
    };
    oci-containers = {
      backend = "docker";
    };
  };

  virtualisation.oci-containers.containers.archlinux = {
    autoStart = true;
    image = "archlinux:latest";
    cmd = [ "/usr/bin/env" "TERM=xterm-256color" "/usr/bin/bash" ];
  };

  users.groups.docker.members = [ "naresh" ];

  environment.systemPackages = with pkgs; [
    docker-compose
    docker-client
  ];
}




# { config, pkgs, lib, ... }:
# let
#   docker = pkgs.docker;
# in
# {

#   # systemd.services.docker-create-container = {
#   #   serviceConfig.Type = "oneshot";
#   #   wantedBy = [ "multi-user.target" ];
#   #   script = ''
#   #     if ! ${docker}/bin/docker inspect -f '{{.Id}}' arch_linux >/dev/null 2>&1; then
#   #        ${docker}/bin/docker run -d --name archlinux -p 8080:8080 archlinux:latest
#   #     fi

#   #   '';
#   # };



#   virtualisation = {
#     docker = {
#       enable = true;
#     };
#     oci-containers = {
#       backend = "docker";
#     };
#   };

#   virtualisation.oci-containers.containers.archlinux = {


#     autoStart = true;

#     #   image = "arch_linux/latest";
#     image = "archlinux:latest";
#     #   imageFile = pkgs.dockerTools.buildImage {

#     #     name = "arch_linux";
#     #     tag = "latest";

#     #     fromImage = "archlinux";
#     #     fromImageName = "archlinux";
#     #     fromImageTag = "latest";

#     #   # copyToRoot = pkgs.buildEnv {
#     #   #   name = "image-root";
#     #   #   paths = [ pkgs.redis ];
#     #   #   pathsToLink = [ "/bin" ];
#     #   # };

#     #   # runAsRoot = ''
#     #   #   #!${pkgs.runtimeShell}
#     #   #   mkdir -p /data
#     #   # '';

#     cmd = [ "/usr/bin/env" "TERM=xterm-256color" "/usr/bin/bash" ];

#     #   # diskSize = 1024;
#     #   # buildVMMemorySize = 512;
#     #   };
#   };

#   users.groups.docker.members = [ "naresh" ];

#   environment.systemPackages = with pkgs; [
#     docker-compose
#     docker-client
#   ];
# }
