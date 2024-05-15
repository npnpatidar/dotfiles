{ config, ... }:
{


  age.secrets = {
    ssh_github_key = {
      file = ../../secrets/ssh_github_key.age;
      mode = "600";
      owner = "naresh";
    };
    ssh_gitserver_key = {
      file = ../../secrets/ssh_gitserver_key.age;
      mode = "600";
      owner = "naresh";
    };
    ssh_oracle_key = {
      file = ../../secrets/ssh_oracle_key.age;
      mode = "600";
      owner = "naresh";
    };
  };

  programs.ssh = {
    extraConfig = ''
      Host github.com
              HostName github.com
              User git
              IdentityFile ${config.age.secrets.ssh_github_key.path}

      Host galma
           HostName home.naresh.world
           User git
           IdentityFile ${config.age.secrets.ssh_gitserver_key.path}
           Port 46587

      Host ralma
           HostName home.naresh.world
           User root 
           IdentityFile ${config.age.secrets.ssh_oracle_key.path}
           Port 46587

      Host nalma
           HostName home.naresh.world
           User naresh
           IdentityFile ${config.age.secrets.ssh_oracle_key.path}
           Port 46587
    '';

    knownHosts = {
      "github.com" = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };

      "home.naresh.world" = {
        hostNames = [ "[home.naresh.world]:46587" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO32al0GNzcSFmPhJQW4A/Ikflj4A38Nhfd8JGY7u85U";
      };
    };
  };


}
