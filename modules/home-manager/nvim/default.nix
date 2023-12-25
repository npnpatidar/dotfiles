{ pkgs, lib, config, ... }:

with lib;
{
  imports = [
    ./keymaps.nix
    ./options.nix
    ./autocmds.nix
    ./reload.nix

    ./plugins/debug.nix
    ./plugins/coding.nix
    ./plugins/editor.nix
    ./plugins/git.nix
    ./plugins/startup.nix
    ./plugins/test.nix

    ./plugins/lsp.nix
    ./plugins/treesitter.nix

    ./plugins/colorscheme.nix
    ./plugins/ui.nix

    ./plugins/ai.nix
    ./plugins/training.nix

    #./plugins/lang/go.nix
    ./plugins/lang/lua.nix
    ./plugins/lang/nix.nix
    ./plugins/lang/html.nix
    #./plugins/lang/markdown.nix
    ./plugins/lang/python.nix
    ./plugins/lang/css.nix
    #./plugins/lang/yaml.nix

    #./plugins/tmux.nix
  ];


  home.file."./.config/nvim" = {
    source = ./config;
    recursive = true;
  };

  programs.nixvim = {
    enable = true;
    extraPlugins = with pkgs.vimPlugins; [ plenary-nvim ];


    # package = pkgs.neovim;

    package = pkgs.neovim-nightly;
  };

}
