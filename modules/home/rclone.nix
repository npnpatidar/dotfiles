{ lib, ... }: {
  flake.homeModules.rclone =
    { config, pkgs, ... }:
    let
      mkRcloneService =
        environment:
        lib.nameValuePair "rclone-${environment}" {
          Service = {
            Type = "simple";
            Environment = "PATH=/run/wrappers/bin";
            ExecStart = "${pkgs.rclone}/bin/rclone bisync ${environment}:/ ${config.home.homeDirectory}/Data/${environment}/Drive --filter-from ${config.home.homeDirectory}/.config/rclone/${environment}.txt --force --drive-import-formats=docx --verbose --create-empty-src-dirs --resilient --check-first --recover";
          };
        };
      mkRcloneSharedService =
        environment:
        lib.nameValuePair "rclone-shared-${environment}" {
          Service = {
            Type = "simple";
            Environment = "PATH=/run/wrappers/bin";
            ExecStart = "${pkgs.rclone}/bin/rclone bisync ${environment}:/ ${config.home.homeDirectory}/Data/${environment}/Shared --filter-from ${config.home.homeDirectory}/.config/rclone/${environment}-shared.txt --drive-import-formats=docx --verbose --create-empty-src-dirs --resilient --check-first --recover --drive-shared-with-me";
          };
        };
      mkSyncTimer =
        environment:
        lib.nameValuePair "rclone-${environment}" {
          Timer = {
            OnBootSec = "2m";
            OnUnitInactiveSec = "5m";
            Unit = "rclone-${environment}.service";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
      mkSharedSyncTimer =
        environment:
        lib.nameValuePair "rclone-shared-${environment}" {
          Timer = {
            OnBootSec = "2m";
            OnUnitInactiveSec = "5m";
            Unit = "rclone-shared-${environment}.service";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
    in
    {
      systemd.user.services =
        builtins.listToAttrs (
          map mkRcloneService [
            "naresh.alternate"
            "npnpatidar"
            "npnpatidarCrypt"
          ]
        )
        // builtins.listToAttrs (map mkRcloneSharedService [ "npnpatidar" ])
        // { };
      systemd.user.timers =
        builtins.listToAttrs (
          map mkSyncTimer [
            "naresh.alternate"
            "npnpatidar"
            "npnpatidarCrypt"
          ]
        )
        // builtins.listToAttrs (map mkSharedSyncTimer [ "npnpatidar" ])
        // { };

      home.file = {
        ".config/rclone/naresh.alternate.txt".text = "- rcloneCrypt/**";
        ".config/rclone/npnpatidar.txt".text = "- rcloneCrypt/**\n- EncryptedDocuments/**";
        ".config/rclone/npnpatidarCrypt.txt".text = "+ *";
        ".config/rclone/npnpatidar-shared.txt".text =
          "+ BOOKS/Naresh\\ books\\ content/Edited\\ By\\ Naresh/**\n- *";
      };
    };
}
