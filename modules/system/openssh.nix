{ lib, ... }: with lib;
{
  flake.nixosModules.openssh = { config, ... }: {
    sops.secrets = {
      ssh_github_key = {
        mode = "0600";
        owner = "${config.systemConstants.default_user}";
      };
      ssh_gitserver_key = {
        mode = "0600";
        owner = "${config.systemConstants.default_user}";
      };
      ssh_oracle_key = {
        mode = "0600";
        owner = "${config.systemConstants.default_user}";
      };
    };

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [
          "${config.systemConstants.default_user}"
        ];
      };
    };

    programs.ssh = {
      extraConfig = ''
        Host github.com
                HostName github.com
                User git
                IdentityFile ${config.sops.secrets.ssh_github_key.path}

        Host git.${config.systemConstants.domain_name}
             HostName git.${config.systemConstants.domain_name}
             User gitea
             IdentityFile ${config.sops.secrets.ssh_gitserver_key.path}
              Port ${toString config.systemConstants.ssh_port}

        Host nalma
             HostName home.${config.systemConstants.domain_name}
             User ${config.systemConstants.default_user}
             IdentityFile ${config.sops.secrets.ssh_oracle_key.path}
             Port ${toString config.systemConstants.ssh_port}
      '';

      knownHosts = {
        "github.com" = {
          hostNames = [ "github.com" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
        "home.${config.systemConstants.domain_name}" = {
          hostNames = [
            "[home.${config.systemConstants.domain_name}]:${toString config.systemConstants.ssh_port}"
          ];
          publicKey = config.systemConstants.host_ssh_key;
        };
        "git.${config.systemConstants.domain_name}" = {
          hostNames = [
            "[git.${config.systemConstants.domain_name}]:${toString config.systemConstants.ssh_port}"
          ];
          publicKey = config.systemConstants.host_ssh_key;
        };
        "alma" = {
          hostNames = [
            "alma"
            "[alma]:${toString config.systemConstants.ssh_port}"
            "alma.n"
            "[alma.n]:${toString config.systemConstants.ssh_port}"
          ];
          publicKey = config.systemConstants.host_ssh_key;
        };
      };
    };
  };
}
