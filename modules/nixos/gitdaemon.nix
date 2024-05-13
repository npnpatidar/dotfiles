{ config
, lib
, pkgs
, ...
}: {

  services.gitDaemon = {
    enable = true;
    # basePath = "/srv/git";
    exportAll = true;
  };
  # networking.firewall.allowedTCPPorts = [ 9418 ];

  users = {
    users.git = {
      home = "/var/lib/gitDaemon";
      createHome = true;
      homeMode = "755";
      isSystemUser = false;
      shell = "${pkgs.bash}/bin/bash";
      group = "git";
      packages = [ pkgs.git ];
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDy+wbDlo4wWVIsmK75dWh+9pIDJPcYa0swCtsLapo2esZtuJZJCgvH0yVXBJP6LNdpbV+7ARI2CQblomJcG03JHtMkcTiQIJU0XRKP33KlfMOSWrC+txbTi6YWqdrpljc9Tbk12dYW7/8bzs1FkoqYoVjqplyALGl7BLlWTphTAHUOaOJ1xX3V7y5EDKmCGfG7C0j9qIt8qq6DS9wg7kQuEKPp1MPjL1iyJqVfP/4KLwn/ATm7RZis7RgQS4W7TyIoSok+hrc7Sbg1rBtua5T/Cb3tgOHM1R3fCwTnJ5QAvCyw9yLxbsz5p2Kd+fTnwHVYopMFHYFprCaXyRstRVdD3+ImbpkH5B0Bxy64yHhymH31mBglqEu9eR8iG3DWy4oMGicFpdKbiXL+O26qsXBmlg+f/oEKTTE0YZVWy8Q226hIE69Wqn0gCHpdKiM9za1l94W9QYzwRLaZnmy1YvPFTjUZCiu59ZuadeTvx4RAPOemhhe4DfJ3+rpZk2ynsg8= gitserver@whatisleft.anonaddy.com" ];
    };
    groups.git = { };
  };
}
