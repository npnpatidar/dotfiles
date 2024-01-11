{ inputs, lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.librewolf;
in
{
  imports = [
    inputs.nur.nixosModules.nur
  ];

  options.modules.home-manager.librewolf = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    home.file.".librewolf/profiles.ini".text = ''
      [Profile0]
      Name=default
      IsRelative=1
      Path=chayleaf
      Default=1

      [General]
      StartWithLastProfile=1
      Version=2
    '';

    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.librewolf-unwrapped {
        inherit (pkgs.librewolf-unwrapped) extraPrefsFiles extraPoliciesFiles;
        wmClass = "LibreWolf";
        libName = "librewolf";
      };
      profiles.chayleaf = {
        name = "chayleaf";
        path = "../../.librewolf/chayleaf";
        extensions = (with config.nur.repos.rycee.firefox-addons; [
          libredirect
          skip-redirect
          bitwarden
          tridactyl
        ]);

      };
    };
  };
}
