{ config, ... }: {
  config.age.secrets."standard".file = ../../secrets/standard.age;
  config.age.secrets."hashedstandard".file = ../../secrets/hashedstandard.age;
  config.age.secrets."htpasswdstandard".file = ../../secrets/htpasswdstandard.age;

}
