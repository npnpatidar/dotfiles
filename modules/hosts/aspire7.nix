{ config, inputs, ... }: {
  flake.nixosConfigurations.aspire7 = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = with config.flake.nixosModules; [
      shared-modules
      { networking.hostName = "aspire7"; }
      # Magic SysRq: sync/unmount/reboot/poweroff survive compositor hangs
      { boot.kernel.sysctl."kernel.sysrq" = 244; }
      aspire7-hardware
      aspire7-packages
      nvidia
      power-management
      apple-support
      nix-aspire7
      networking-aspire7
      bootloader-aspire7
      syncthing-aspire7
      containerization-aspire7
      immich
      sound
      fonts
      bluetooth
      printing
      flatpak
      appimage
      niri
      umbriel
      removable-media
      stylix
      noctalia
      inputs.stylix.nixosModules.stylix
    ];
  };

  flake.homeConfigurations."naresh@aspire7" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = { inherit inputs; };
    modules = with config.flake.homeModules; [
      shared-modules
      vscode
      dictation
      aspire7-packages
      chromium
      opencode
      obsidian
      geary
      mpv
      imv
      sioyek
      zed-editor
      niri
      umbriel
      removable-media
      filen-desktop
      kdeconnect
      mcp
      notebooklm
      noctalia
      nur
      xdg
      gtk
      kitty
      flatpak
      stylix
      inputs.stylix.homeModules.default
      onlyoffice
      zen-browser
      librewolf
      voxtype
      inputs.nix-index-database.homeModules.nix-index
      inputs.quadlet-nix.homeManagerModules.quadlet
      {
        home.sessionVariables = {
          BROWSER = "zen-beta";
          TERMINAL = "kitty";
        };
        xdg.configFile."yazi/theme.toml".force = true;
      }
    ];
  };
}
