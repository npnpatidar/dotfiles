_: {
  flake.homeModules.neovim =
    { pkgs, inputs, ... }:
    let
      # Flags shared by all extras here: install their tool dependencies via
      # nix instead of downloading them at runtime through mason.
      withDeps = {
        enable = true;
        installDependencies = true;
        installRuntimeDependencies = true;
      };
    in
    {
      imports = [ inputs.lazyvim.homeManagerModules.default ];

      programs = {
        lazyvim = {
          enable = true;

          extras = {
            lang = {
              # LSP: nil; formatter: nixfmt; linter: statix
              nix = withDeps;
              # LSP: pyright + ruff; formatter: ruff; venv-selector
              python = withDeps;
              # LSP: marksman; formatter: prettier/markdownlint/markdown-toc;
              # preview: render-markdown + markdown-preview
              markdown = withDeps;
              # LSP: jsonls; schema support: SchemaStore.nvim; json5 treesitter
              json = withDeps;
              # LSP: yamlls; schema support: SchemaStore.nvim;
              # formatter: prettier; linter: yamllint (configured below)
              yaml = withDeps;
            };
            # prettier formatting for markdown (and js/ts/json/yaml...)
            formatting.prettier = withDeps;
          };

          # LSPs/tools not covered by the extras' dependency mappings
          extraPackages = with pkgs; [
            bash-language-server # shell LSP
            marksman # markdown LSP
            nil # nix language server
            nixfmt # nix formatter
            pyright # python LSP
            shellcheck # shell linter
            shfmt # shell formatter
            statix # nix linter
            yaml-language-server # yaml LSP
            yamllint # yaml linter
          ];

          # No lang.sh extra in current LazyVim — shell support is configured
          # manually (treesitter bash parser is already in core).
          plugins = {
            shell = ''
              return {
                {
                  "neovim/nvim-lspconfig",
                  opts = {
                    servers = {
                      bashls = {},
                    },
                  },
                },
                {
                  "stevearc/conform.nvim",
                  opts = {
                    formatters_by_ft = {
                      sh = { "shfmt" },
                      bash = { "shfmt" },
                    },
                  },
                },
                {
                  "mfussenegger/nvim-lint",
                  opts = {
                    linters_by_ft = {
                      sh = { "shellcheck" },
                      bash = { "shellcheck" },
                    },
                  },
                },
              }
            '';

            # The lang.yaml extra does not wire up a linter — add yamllint here.
            yaml = ''
              return {
                {
                  "mfussenegger/nvim-lint",
                  opts = {
                    linters_by_ft = {
                      yaml = { "yamllint" },
                    },
                  },
                },
              }
            '';
          };
        };

        # keep the vi/vim aliases from the previous setup
        neovim = {
          viAlias = true;
          vimAlias = true;
        };
      };
    };
}
