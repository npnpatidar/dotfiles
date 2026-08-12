_: {
  flake.modules.generic.systemConstants = { lib, ... }: {
    options.systemConstants = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
      description = ''
        System-wide constants — values that are the same on every
        host and don't fit any existing aspect.
      '';
    };
    config.systemConstants = {
      domain_name = "rajedu.in";
      default_user = "naresh";
      home_directory = "/home/naresh";
      data_directory = "/home/naresh/Data";
      user_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC928hf7NiG16DmhPbizMXZvDuIhiLBqhi7+zWCu4L2v naresh@nixos";
      ssh_port = 46587;
      git_email = "7de6dkm1@duck.com";
      acme_email = "letsencrypt@whatisleft.anonaddy.com";
      host_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdPV9fAM7dXg/djTSJRt8Q52o5TNWlDOhSM3IlyoBE4";
    };
  };
}
