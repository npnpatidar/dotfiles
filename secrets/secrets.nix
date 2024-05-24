let

  naresh = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pK+/SUI3dPB1tQ0nF4Gp9BKKGMHnJ1bBSiYJX2sCHgbfOmDKAlAnuRTP6Zhp6BTZ5LwNC/4pI76bnpmo8YjjGNGkPlMHfOHrn8rm2Hhyx7RVHyMLGKYQdNtzBcfPgDUqrXPM3cdCMya15BnavXE4fOYUoGgIvOolTveWfngHRjQNptTlfpQoIjMRIvIfhu+xLiikJVm4EbgzEVu6U8OdGuV8eq33GYc+HORqKRq+jILIT5V3q4OTcCbORbStt4Zq4WumoVWXuM3abmzpA0nCAbZM8ArWQ8UujOM490hyQVGqfZae8FS1ADGAyEybrHMIMxT0IysZ7xW+tnaljIpt";

  users = [ naresh ];
  alma = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO32al0GNzcSFmPhJQW4A/Ikflj4A38Nhfd8JGY7u85U";
  aspire7 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOF/MJKLcRnQ2l+js1CyWC0NLnWZF/nAMql+toM7esy";
  # root = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBFUd9Mbn2qNGKnmu34E03bthRfBtkeuDAsLlZ4tLAJMXyi/GnohlQplUkmDqvgc9u9RmeaUgNi6k6mXRaNCJ+u7J5sRhVZVROBj6Qok1LIgLRV4gewkCWNBcbFthDpV3V98BDx/d1lC4qynqu0aYfqKjq4Mj5mcCN6qyeuLX8wmZ21kEolJwuDxB3TzybOwi6Jwa/+tMP/UE0CCs0TAlzvj3nCkZ/gL/JG36p2JONsTXPablD0nBArUV6D69Twd3wTcIxlBPd2RpWf56/QCjPzqJOKbGYIZl4QkRYgx1TOCZyj7Ct1mJN0yf8rkJr+D9hsWCMALse0tsn0Lmk9t2iXriRGB/GPDvzxgakuGBos7tJL3bim8m/XpkWBw958N/g+/l+aDd6xkW2YBWH3SbpKClu7dPBngtS+RlJ6H4hbKfjI4bF3SwN1/SesLL534lqt0g0i8STNltof5xvm2wM7KNWy5lxURCQHxwWbzU4ysBwq8upvW0CLrFdDfhXeLc=";


  systems = [ alma aspire7 ];

  # system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  # system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEYcLpcPdJLrTdNgZ2gznOHCAxMdaceTUT1";
  # systems = [ system1 system2 ];
in
{
  "standard.age".publicKeys = users ++ systems;
  "hashedstandard.age".publicKeys = users ++ systems;
  "htpasswdstandard.age".publicKeys = users ++ systems;
  "nextcloud_admin_password.age".publicKeys = users ++ systems;
  "tailscale_key.age".publicKeys = users ++ systems;
  "rclone_config.age".publicKeys = users ++ systems;
  "ssh_github_key.age".publicKeys = users ++ systems;
  "ssh_gitserver_key.age".publicKeys = users ++ systems;
  "ssh_oracle_key.age".publicKeys = [ aspire7 alma ];
  "freshrss_password.age".publicKeys = [ aspire7 alma ];
  "anki_password.age".publicKeys = users ++ systems;
  "paperless_password.age".publicKeys = users ++ systems;
  "vscode_htpassword.age".publicKeys = users ++ systems;
  "groq_api_key.age".publicKeys = users ++ systems;
  "openrouter_api_key.age".publicKeys = users ++ systems;
}

