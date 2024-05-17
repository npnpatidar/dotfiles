{ pkgs
, ...
}: {


  services.gitea = {
    enable = true;
    # user = "git";
    settings = {
      server = {
        SSH_PORT = 46587;
        HTTP_PORT = 5654;
        # ROOT_URL = "https://test.naresh.world";
        DOMAIN = "git.naresh.world";
        # ROOT_URL = "git.naresh.world";
        # PROTOCOL = "https";
        # httpAddress = "127.0.0.1";
      };
    };
  };

  services.nginx = {
    virtualHosts."git.naresh.world" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5654";
      };
    };
    #


  };

  # services.gitea-actions-runner = {
  # package = pkgs.forgejo-actions-runner;
  # instances.neutrino = {
  #   enable = true;
  #   url = "https://git.neutrino.su";
  #   tokenFile = "/run/forgejo-token";
  #   name = "whale";
  #   labels = [ "ubuntu-latest:docker://node:16-bullseye" ];
  #   settings = {
  #     capacity = 4;
  #   };
  # };




  # services.gitDaemon = {
  #   enable = true;
  #   exportAll = true;
  # };
  #
  users = {
    users.gitea = {
      # home = "/var/lib/gitDaemon";
      createHome = false;
      # homeMode = "755";
      # isSystemUser = false;
      shell = "${pkgs.bash}/bin/bash";
      group = "gitea";
      # packages = [ pkgs.git pkgs.gitea ];
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDy+wbDlo4wWVIsmK75dWh+9pIDJPcYa0swCtsLapo2esZtuJZJCgvH0yVXBJP6LNdpbV+7ARI2CQblomJcG03JHtMkcTiQIJU0XRKP33KlfMOSWrC+txbTi6YWqdrpljc9Tbk12dYW7/8bzs1FkoqYoVjqplyALGl7BLlWTphTAHUOaOJ1xX3V7y5EDKmCGfG7C0j9qIt8qq6DS9wg7kQuEKPp1MPjL1iyJqVfP/4KLwn/ATm7RZis7RgQS4W7TyIoSok+hrc7Sbg1rBtua5T/Cb3tgOHM1R3fCwTnJ5QAvCyw9yLxbsz5p2Kd+fTnwHVYopMFHYFprCaXyRstRVdD3+ImbpkH5B0Bxy64yHhymH31mBglqEu9eR8iG3DWy4oMGicFpdKbiXL+O26qsXBmlg+f/oEKTTE0YZVWy8Q226hIE69Wqn0gCHpdKiM9za1l94W9QYzwRLaZnmy1YvPFTjUZCiu59ZuadeTvx4RAPOemhhe4DfJ3+rpZk2ynsg8= gitserver@whatisleft.anonaddy.com" ];
    };
    groups.gitea = { };
  };
}
