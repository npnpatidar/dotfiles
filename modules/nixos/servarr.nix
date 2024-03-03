{ pkgs, ... }:
{

  services = {
    radarr = {
      #7878
      enable = true;
      user = "root";
      group = "users";
      openFirewall = true;
    };
    sonarr = {
      #8989
      enable = true;
      user = "root";
      group = "users";
      openFirewall = true;
    };
    bazarr = {
      #6767
      enable = true;
      user = "root";
      group = "users";
      openFirewall = true;
    };

    prowlarr = {
      #9696
      enable = true;
      openFirewall = true;
    };

    jackett = {
      #9117
      enable = true;
      openFirewall = true;
    };

    jellyfin = {
      #9117
      enable = true;
      user = "root";
      group = "users";
      openFirewall = true;
    };


  };


  environment.systemPackages = with pkgs; [
    qbittorrent
  ];



}
