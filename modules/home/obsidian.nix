_: {
  flake.homeModules.obsidian =
    { lib, pkgs, ... }:
    let
      # Obsidian community plugins; see pkgs/obsidian-plugin.nix for how to bump.
      mkPlugin = import ../../pkgs/obsidian-plugin.nix { inherit pkgs lib; };
    in
    {
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
          eoro = {
            enable = true;
            target = "Data/Sync_M_L_I_C/Notes/EORO";
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
          communityPlugins = [
            (mkPlugin {
              id = "canvas-mindmap";
              repo = "quorafind/obsidian-canvas-mindmap";
              version = "1.0.2";
              mainJsHash = "0y1z0kfp27zgbhbdr820pcbhd96c7imxbyk6rlmr7qz3prkqfpv0";
              manifestHash = "1b1n3jkjlmc72q8q6k7gxi7kfb53xvq1nwglmcv88vn5wimaapw4";
              stylesCssHash = "0xzsdl83zn6r60lhwfgb9kgw51dkraymy122jcikibg76z2wylkj";
            })
            (mkPlugin {
              id = "advanced-canvas";
              repo = "Developer-Mike/obsidian-advanced-canvas";
              version = "7.0.0";
              mainJsHash = "0fj7nvrc1k942dsb6ddsfqj6lianx4fmxv6myv4fgjdh6hxx9ar3";
              manifestHash = "0lfp1fla7rcq17rfv3fqbz95rx33i5r7jxkslcz911fisl9xxxgz";
              stylesCssHash = "0b4j4f4r7nwdv2lgj46i330ifag8ja9w3zn9gwmm9rb0j55q0iin";
            })
            (mkPlugin {
              id = "simple-canvasearch";
              repo = "ddalexb/obsidian-simple-canvasearch";
              version = "1.0.2";
              mainJsHash = "1ygvrgrbwf8khbc4dra7rp4c75s292nqpv31j27ssyxls1g0qmqg";
              manifestHash = "1p9wibfm1rx5wawg6z5wgapjxdlib82xbcm7bzqjja6rpla0dfvj";
            })
            (mkPlugin {
              id = "optimize-canvas-connections";
              repo = "felixchenier/obsidian-optimize-canvas-connections";
              version = "1.0.0";
              mainJsHash = "1wqpyibrnyfaf30s82m0id6brkbl3qsdhnqzd86s2avva42479xi";
              manifestHash = "1hldyc0gf2l6pawwc4myvawmzajgmjdv7y24icx0yhr38hxm4gnk";
            })
            (mkPlugin {
              id = "canvas-compact";
              repo = "npnpatidar/obsidian-canvas-compact";
              version = "1.3.3";
              mainJsHash = "11sb0ya786sq4v8dbjzcwlbz6bj3bvlbni9mvf2j0y7pfwa9dp4g";
              manifestHash = "0hvf0igqrkrzp322j47fdn4sfh1p39g6gjvw0kzrx1dyn0r1y2i9";
            })
          ];
        };
      };
    };
}
