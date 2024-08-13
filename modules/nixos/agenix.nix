{ config, ... }: {
  config.age.secrets = {
    "standard".file = ../../secrets/standard.age;
    "hashedstandard".file = ../../secrets/hashedstandard.age;
    "htpasswdstandard".file = ../../secrets/htpasswdstandard.age;
    "tailscale_key".file = ../../secrets/tailscale_key.age;
    "rclone_config".file = ../../secrets/rclone_config.age;
    "ssh_github_key".file = ../../secrets/ssh_github_key.age;
    "ssh_gitserver_key".file = ../../secrets/ssh_gitserver_key.age;
    "ssh_oracle_key".file = ../../secrets/ssh_oracle_key.age;
    "freshrss_password".file = ../../secrets/freshrss_password.age;
    "anki_password".file = ../../secrets/anki_password.age;
    "paperless_password".file = ../../secrets/paperless_password.age;
    "vscode_htpassword".file = ../../secrets/vscode_htpassword.age;
    "groq_api_key".file = ../../secrets/groq_api_key.age;
    "openrouter_api_key".file = ../../secrets/openrouter_api_key.age;
    "syncthing_gui_password".file = ../../secrets/syncthing_gui_password.age;
    "open_webui_environment_file".file = ../../secrets/open_webui_environment_file.age;
    "obsidian_couchdb_environment_file".file = ../../secrets/obsidian_couchdb_environment_file.age;
    "gitea_action_runner_token".file = ../../secrets/gitea_action_runner_token.age;
  };
}
