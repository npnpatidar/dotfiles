{ config, ... }: {
  config.age.secrets."standard".file = ../../secrets/standard.age;
}
