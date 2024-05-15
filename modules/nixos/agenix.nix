{ config, ... }: {
  config.age.secrets."standard".file = ../../secrets/standard.age;
  config.age.secrets."hashedstandard".file = ../../secrets/hashedstandard.age;
  config.age.secrets."htpasswdstandard".file = ../../secrets/htpasswdstandard.age;
  config.age.secrets."tailscale_key".file = ../../secrets/tailscale_key.age;
  config.age.secrets."rclone_config".file = ../../secrets/rclone_config.age;
  config.age.secrets."ssh_github_key".file = ../../secrets/ssh_github_key.age;
  config.age.secrets."ssh_gitserver_key".file = ../../secrets/ssh_gitserver_key.age;
}
