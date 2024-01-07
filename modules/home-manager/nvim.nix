{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.nvim;
in
{
  options.modules.home-manager.nvim = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

 programs.neovim =
    {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = false;
      withPython3 = true;

      plugins = with pkgs.vimPlugins; [
        {
          plugin = lazy-nvim;
          type = "lua";
          config = ''
            require("core")

            require("lazy").setup({ { import = "plugins" } , 
            })
          '';
        }

	LazyVim
      ];

    };
  };
}
