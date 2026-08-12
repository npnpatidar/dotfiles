_: {
  flake.homeModules.zed-editor = { pkgs, ... }: {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "json"
        "catppuccin-blur"
        "catppuccin"
        "material-icon-theme"
        "python-requirements"
        "mcp-server-puppeteer"
        "python-snippets"
      ];
      extraPackages = with pkgs; [
        python3Packages.python-lsp-server
        tinymist
        nixd
        nixfmt
        nil
      ];
      installRemoteServer = true;
    };
  };
}
