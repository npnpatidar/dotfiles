{ lib, pkgs, config, ... }:
let
  mkRcloneService = environment:
    lib.nameValuePair "rclone-${environment}" {
      Service = {
        Type = "simple";
        Environment = "PATH=/run/wrappers/bin";

        ExecStart = ''
          ${pkgs.rclone}/bin/rclone bisync ${environment}:/ ${config.home.homeDirectory}/Data/${environment}/Drive  --filter-from   ${config.home.homeDirectory}/.config/rclone/${environment}.txt  --force  --drive-import-formats=docx --verbose --create-empty-src-dirs  --resilient --check-first  --recover

        '';
      };
    };

  mkRcloneSharedService = environment:
    lib.nameValuePair "rclone-shared-${environment}" {
      Service = {
        Type = "simple";
        Environment = "PATH=/run/wrappers/bin";

        ExecStart = ''
          ${pkgs.rclone}/bin/rclone bisync ${environment}:/ ${config.home.homeDirectory}/Data/${environment}/Shared  --filter-from   ${config.home.homeDirectory}/.config/rclone/${environment}-shared.txt  --drive-import-formats=docx --verbose --create-empty-src-dirs  --resilient --check-first  --recover --drive-shared-with-me

        '';
      };
    };

  mkSyncTimer = environment:
    lib.nameValuePair "rclone-${environment}" {
      Timer = {
        # 5 minutes after boot
        OnBootSec = "2m";
        # 5 minutes after last finished
        OnUnitInactiveSec = "5m";
        # run once when the timer is started
        Unit = "rclone-${environment}.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };

  mkSharedSyncTimer = environment:
    lib.nameValuePair "rclone-shared-${environment}" {
      Timer = {
        # 5 minutes after boot
        OnBootSec = "2m";
        # 5 minutes after last finished
        OnUnitInactiveSec = "5m";
        # run once when the timer is started
        Unit = "rclone-shared-${environment}.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
in
{
  systemd.user.services = builtins.listToAttrs
    (map mkRcloneService [
      "naresh.alternate"
      "npnpatidar"
      "npnpatidarCrypt"
    ]) // builtins.listToAttrs (map mkRcloneSharedService [
    "npnpatidar"
  ]) // { };

  systemd.user.timers = builtins.listToAttrs
    (map mkSyncTimer [
      "naresh.alternate"
      "npnpatidar"
      "npnpatidarCrypt"
    ]) // builtins.listToAttrs (map mkSharedSyncTimer [
    "npnpatidar"
  ]) // { };


  # rclone bisync naresh.alternate: ~/Data/naresh.alternate --resync --filter-from ~/.config/rclone/naresh.alternate.txt 
  # for the first time and similarly for other services untill this command is not successful service won't run
  # + Normal/** to inclue files 
  # - rcloneCrypt/** to exclude files
  # you can check the status of the service using systemctl --user status rclone-naresh.alternate.service


  home.file.".config/rclone/naresh.alternate.txt".text = ''
    - rcloneCrypt/**
  '';
  home.file.".config/rclone/npnpatidar.txt".text = ''
    - rcloneCrypt/**
    - EncryptedDocuments/**
  '';

  home.file.".config/rclone/npnpatidarCrypt.txt".text = ''
    + *
  '';
  home.file.".config/rclone/npnpatidar-shared.txt".text = ''
    + BOOKS/Naresh\ books\ content/Edited\ By\ Naresh/**
    - *
  '';
}


