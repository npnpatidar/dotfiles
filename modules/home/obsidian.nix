_: {
  flake.homeModules.obsidian = { lib, ... }: {
    programs.obsidian = {
      enable = true;
      vaults = {
        General = {
          enable = true;
          target = "Data/Sync_M_L_I_C/Notes/General";
        };
        rajasthan = {
          enable = true;
          target = "Data/Sync_M_L_I_C/Notes/rajasthan";
        };
      };
      defaultSettings = {
        app = {
          vimMode = false;
          readableLineLength = false;
          showLineNumber = true;
          useTab = true;
          newFileLocation = "latest";
          trashOption = "local";
        };
        appearance = lib.mkForce {
          baseFontSizeAction = true;
          theme = "obsidian";
          baseFontSize = 21;
        };
        corePlugins = [
          "backlink"
          "bookmarks"
          "canvas"
          "command-palette"
          "editor-status"
          "file-explorer"
          "file-recovery"
          "global-search"
          "outgoing-link"
          "outline"
          "page-preview"
        ];
        communityPlugins = [ ];
      };
    };
  };
}
