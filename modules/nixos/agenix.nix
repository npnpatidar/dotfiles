{ config, ... }: {
  config.age.secrets."standard".file = ../../secrets/standard.age;
  config.age.secrets."hashedstandard".file = ../../secrets/hashedstandard.age;
  config.age.secrets."htpasswdstandard".file = ../../secrets/htpasswdstandard.age;
  config.age.secrets."tailscale_key".file = ../../secrets/tailscale_key.age;
  config.age.secrets."rclone_config".file = ../../secrets/rclone_config.age;
  config.age.secrets."ssh_github_key".file = ../../secrets/ssh_github_key.age;
  config.age.secrets."ssh_gitserver_key".file = ../../secrets/ssh_gitserver_key.age;
  config.age.secrets."ssh_oracle_key".file = ../../secrets/ssh_oracle_key.age;
  config.age.secrets."freshrss_password".file = ../../secrets/freshrss_password.age;
  config.age.secrets."anki_password".file = ../../secrets/anki_password.age;
  config.age.secrets."paperless_password".file = ../../secrets/paperless_password.age;
  config.age.secrets."vscode_htpassword".file = ../../secrets/vscode_htpassword.age;
}
