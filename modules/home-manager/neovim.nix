{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.neovim;
in
{
  options.modules.home-manager.neovim = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {


    programs.nixvim = {
      enable = true;
      package = pkgs.neovim-unwrapped;


      extraConfigLua = ''


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

vim.g.mapleader = " " 

require("lazy").setup({
    spec = {
        --------------------------------------------------------------------------------
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },

        --------------------------------------------------------------------------------
        {"sbdchd/neoformat"},
        --{"ms-jpq/chadtree" , opt = {}},

        --------------------------------------------------------------------------------
        {
        'Exafunction/codeium.vim',
        config = function ()

                vim.keymap.set('i', '<C-a>', function () return vim.fn['codeium#Accept']() end, { expr = true, desc = "Codeium Accept"})
                vim.keymap.set('i', '<C-e>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, desc = "Codeium Next Suggestion" })
        end
        },

        --------------------------------------------------------------------------------
        {
            "nvim-cmp",
            dependencies = {
                                {
                                    "Exafunction/codeium.vim",
                                    cmd = "Codeium",
                                    build = ":Codeium Auth",
                                    opts = {},
                                },
                            },
                            ---@param opts cmp.ConfigSchema
                            opts = function(_, opts)
                            table.insert(opts.sources, 1,  {
                                                                name = "codeium",
                                                                group_index = 1,
                                                                priority = 100,
                                                        })
                                    end,
        },


        --------------------------------------------------------------------------------
    {
      "nvim-treesitter/nvim-treesitter",
      version = false, -- last release is way too old and doesn't work on Windows
      build = ":TSUpdate",
      event = { "LazyFile", "VeryLazy" },
      init = function(plugin)
        -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
        -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
        -- no longer trigger the **nvim-treeitter** module to be loaded in time.
        -- Luckily, the only thins that those plugins need are the custom queries, which we make available
        -- during startup.
        require("lazy.core.loader").add_to_rtp(plugin)
        require("nvim-treesitter.query_predicates")
      end,
      dependencies = {
        {
          "nvim-treesitter/nvim-treesitter-textobjects",
          config = function()
            -- When in diff mode, we want to use the default
            -- vim text objects c & C instead of the treesitter ones.
            local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
            local configs = require("nvim-treesitter.configs")
            for name, fn in pairs(move) do
              if name:find("goto") == 1 then
                move[name] = function(q, ...)
                  if vim.wo.diff then
                    local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                    for key, query in pairs(config or {}) do
                      if q == query and key:find("[%]%[][cC]") then
                        vim.cmd("normal! " .. key)
                        return
                      end
                    end
                  end
                  return fn(q, ...)
                end
              end
            end
          end,
        },
      },
      cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
      keys = {
        { "<c-space>", desc = "Increment selection" },
        { "<bs>", desc = "Decrement selection", mode = "x" },
      },
      ---@type TSConfig
      ---@diagnostic disable-next-line: missing-fields
      opts = {
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          "bash",
          "nix",
          "c",
          "html",
          "javascript",
          "jsdoc",
          "json",
          "jsonc",
          "lua",
          "luadoc",
          "luap",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
        },
      },
      ---@param opts TSConfig
      config = function(_, opts)
        if type(opts.ensure_installed) == "table" then
          ---@type table<string, boolean>
          local added = {}
          opts.ensure_installed = vim.tbl_filter(function(lang)
            if added[lang] then
              return false
            end
            added[lang] = true
            return true
          end, opts.ensure_installed)
        end
        require("nvim-treesitter.configs").setup(opts)
      end,
    },
    ------------------------------------------------------------------------------------------------


{

  "williamboman/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = ":MasonUpdate",
  opts = {
    ensure_installed = {
      "stylua",
      "shfmt",
      "rnix-lsp",
      "nil",
    },
  },
  ---@param opts MasonSettings | {ensure_installed: string[]}
  config = function(_, opts)
    require("mason").setup(opts)
    local mr = require("mason-registry")
    mr:on("package:install:success", function()
      vim.defer_fn(function()
        -- trigger FileType event to possibly load this newly installed LSP server
        require("lazy.core.handler.event").trigger({
          event = "FileType",
          buf = vim.api.nvim_get_current_buf(),
        })
      end, 100)
    end)
    local function ensure_installed()
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end
    if mr.refresh then
      mr.refresh(ensure_installed)
    else
      ensure_installed()
    end
  end,
},


----------------------------------------------------------------------------------------------

{
"sbdchd/neoformat"
  },




    ----------------------------------------------------------------------------------------------


{
  "nomnivore/ollama.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  -- All the user commands added by the plugin
  cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },

  keys = {
    -- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
    {
      "<leader>oo",
      ":<c-u>lua require('ollama').prompt()<cr>",
      desc = "ollama prompt",
      mode = { "n", "v" },
    },

    -- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
    {
      "<leader>oG",
      ":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
      desc = "ollama Generate Code",
      mode = { "n", "v" },
    },
  },

  ---@type Ollama.Config
  opts = {
    model = "mistral",
    url = "http://127.0.0.1:11434",
    serve = {
      on_start = false,
      command = "ollama",
      args = { "serve" },
      stop_command = "pkill",
      stop_args = { "-SIGTERM", "ollama" },
    },
    -- View the actual default prompts in ./lua/ollama/prompts.lua
    prompts = {
      Sample_Prompt = {
        prompt = "This is a sample prompt that receives $input and $sel(ection), among others.",
        input_label = "> ",
        model = "mistral",
        action = "display",
      }
    }
  }
},



------------------------------------------------------------------------------------------------





      ------------------------------------------------------------------------------------------------































        --------------------------------------------------------------------------------
},
    
    defaults = {
        lazy = true,
        version = false,
    },
})


  vim.g.codeium_disable_bindings = 1
  vim.g.neoformat_run_all_formatters = 1
vim.g.neoformat_enabled_nix = {'nixfmt'}







    '';

    };
  };
}
