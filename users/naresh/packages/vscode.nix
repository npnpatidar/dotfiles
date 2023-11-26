{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium-fhs;
    extensions = with pkgs.vscode-extensions;[
      mhutchie.git-graph
      github.vscode-pull-request-github
      esbenp.prettier-vscode
      arrterian.nix-env-selector
      mkhl.direnv
      jnoortheen.nix-ide
      ms-python.python

    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "codeium";
        publisher = "codeium";
        version = "1.4.20";
        sha256 = "sha256-3k5hgpV+wVnHMhVk+oJrGaZ+RjXhfIZIa3PdvPelc1Y=";
      }
      {
        name = "nix-ide";
        publisher = "jnoortheen";
        version = "0.2.2";
        sha256 = "sha256-jwOM+6LnHyCkvhOTVSTUZvgx77jAg6hFCCpBqY8AxIg=";
      }
      
    ];
  };
}
