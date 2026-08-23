{ lib, ... }: with lib;
{
  flake.nixosModules.users =
    {
      config,
      pkgs,
      ...
    }:
    {
      sops.secrets = {
        hashedstandard = { };
        standard = { };
      };

      users.users."${config.systemConstants.default_user}" = {
        isNormalUser = true;
        description = "${config.systemConstants.default_user}";
        extraGroups = [
          "networkmanager"
          "wheel"
          "kvm"
          "input"
          "disk"
        ];
        createHome = true;
        home = "${config.systemConstants.home_directory}";
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
          config.systemConstants.user_ssh_key
        ];
        hashedPasswordFile = config.sops.secrets."hashedstandard".path;
        autoSubUidGidRange = true;
        linger = true;
      };

      # Passwordless sudo for Nix operations, restricted to a single binary:
      # nixos-rebuild. The pi coding agent (running as
      # ${config.systemConstants.default_user}) switches the system with
      # `sudo nixos-rebuild switch` — it handles the rest as root internally.
      #
      # Also allow the agent to manage any system service via systemctl,
      # but only the service-management subcommands (start/stop/restart/
      # status/reload). User services need no sudo at all: they are managed
      # with `systemctl --user` and linger is enabled below.
      #
      # timestamp_timeout=0: never cache credentials — every non-allowlisted
      # sudo command asks again (via the interactive askpass dialog).
      security.sudo.extraConfig = ''
        Defaults timestamp_timeout=0
      '';
      security.sudo.extraRules = [
        {
          users = [ config.systemConstants.default_user ];
          commands = [
            {
              command = "/run/current-system/sw/bin/nixos-rebuild";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl start *";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl stop *";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl restart *";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl status *";
              options = [ "NOPASSWD" ];
            }
            # `systemctl status` without a unit (overall state) — `*` requires an argument
            {
              command = "/run/current-system/sw/bin/systemctl status";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl reload *";
              options = [ "NOPASSWD" ];
            }
            # Read-only log inspection (journalctl has no state-changing flags
            # worth worrying about; output paging is handled by the agent).
            {
              command = "/run/current-system/sw/bin/journalctl *";
              options = [ "NOPASSWD" ];
            }
            # `journalctl` without any arguments — `*` requires an argument
            {
              command = "/run/current-system/sw/bin/journalctl";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      programs.zsh.enable = true;
    };
}
