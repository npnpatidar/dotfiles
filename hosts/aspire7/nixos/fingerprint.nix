{ pkgs, ... }: {


  security.pam.services.login.fprintAuth = true;
  services.fprintd = {
    enable = true;
    # tod.enable = true;
    # tod.driver = pkgs.libfprint-2-tod1-elan;
    # tod.driver = pkgs.libfprint-2-tod1-vfs0090;
    # tod.driver = pkgs.libfprint;

  };

  environment.systemPackages = with pkgs;[
    # libfprint-tod
    # libfprint-2-tod1-elan
    libfprint
  ];

}


