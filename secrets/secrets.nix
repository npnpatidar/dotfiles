let

  naresh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO32al0GNzcSFmPhJQW4A/Ikflj4A38Nhfd8JGY7u85U";
  root = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBFUd9Mbn2qNGKnmu34E03bthRfBtkeuDAsLlZ4tLAJMXyi/GnohlQplUkmDqvgc9u9RmeaUgNi6k6mXRaNCJ+u7J5sRhVZVROBj6Qok1LIgLRV4gewkCWNBcbFthDpV3V98BDx/d1lC4qynqu0aYfqKjq4Mj5mcCN6qyeuLX8wmZ21kEolJwuDxB3TzybOwi6Jwa/+tMP/UE0CCs0TAlzvj3nCkZ/gL/JG36p2JONsTXPablD0nBArUV6D69Twd3wTcIxlBPd2RpWf56/QCjPzqJOKbGYIZl4QkRYgx1TOCZyj7Ct1mJN0yf8rkJr+D9hsWCMALse0tsn0Lmk9t2iXriRGB/GPDvzxgakuGBos7tJL3bim8m/XpkWBw958N/g+/l+aDd6xkW2YBWH3SbpKClu7dPBngtS+RlJ6H4hbKfjI4bF3SwN1/SesLL534lqt0g0i8STNltof5xvm2wM7KNWy5lxURCQHxwWbzU4ysBwq8upvW0CLrFdDfhXeLc=";


  users = [ root naresh ];

  # system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  # system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEYcLpcPdJLrTdNgZ2gznOHCAxMdaceTUT1";
  # systems = [ system1 system2 ];
in
{
  "standard.age".publicKeys = users;
  "hashedstandard.age".publicKeys = users;
  "htpasswdstandard.age".publicKeys = users;
  "nextcloud_admin_password.age".publicKeys = users;
  # "secret2.age".publicKeys = users ++ systems;
}

