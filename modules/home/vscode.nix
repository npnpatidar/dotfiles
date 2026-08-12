_: {
  flake.homeModules.vscode = { pkgs, ... }: {
    programs.vscodium = {
      enable = true;
      package = pkgs.vscodium-fhs;
      profiles.default.extensions =
        with pkgs.vscode-extensions;
        [
          mhutchie.git-graph
          github.vscode-pull-request-github
          esbenp.prettier-vscode
          arrterian.nix-env-selector
          mkhl.direnv
          jnoortheen.nix-ide
          ms-python.python
          continue.continue
          dotjoshjohnson.xml
          zaaack.markdown-editor
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "claude-dev";
            publisher = "saoudrizwan";
            version = "3.5.0";
            sha256 = "sha256-PzKm36S+NgdNpgyi1XaySZVQeGyzZHibAGUB/4aKxkU=";
          }
        ];
    };
  };
}
