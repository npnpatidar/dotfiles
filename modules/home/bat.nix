_: {
  flake.homeModules.bat = { pkgs, ... }: {
    programs.zsh.shellAliases = {
      "-g -- --help" = "--help 2>&1 | bat --language=help --style=plain";
      "-g -- -h" = "-h 2>&1 | bat --language=help --style=plain";
      cat = "bat";
      rg = "batgrep";
      ripgrep = "batgrep";
      man = "batman";
    };
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
      extraPackages = with pkgs.bat-extras; [
        batgrep
        batman
        batwatch
      ];
    };
  };
}
