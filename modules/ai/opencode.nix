_: {
  flake.nixosModules.opencode = { config, ... }: {
    sops.secrets.opencode_password_web = {
      mode = "0600";
      owner = "${config.systemConstants.default_user}";
    };

    services.oink.domains = [
      {
        domain = "${config.systemConstants.domain_name}";
        subdomain = "opencode";
      }
    ];

    services.nginx.virtualHosts."opencode.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4096";
      };
    };
  };

  flake.homeModules.opencode =
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.opencode = {
        enable = true;
        settings = {
          model = "opencode/mimo-v2.5-free";
          small_model = "opencode/deepseek-v4-flash";
          autoshare = false;
          autoupdate = true;
          default_agent = "build";

          share = "manual";

          mcp = {
            nixos = {
              type = "local";
              command = [
                "uvx"
                "mcp-nixos"
              ];
              enabled = true;
            };
            context7 = {
              type = "remote";
              url = "https://mcp.context7.com/mcp";
              enabled = true;
            };
          };

          permission = {
            tool = {
              "*" = "allow";
            };
            skill = {
              "*" = "allow";
            };
            bash = {
              "git commit *" = "ask";
              "git push *" = "ask";
              "git reset --hard *" = "deny";
              "rm -rf *" = "ask";
              "sudo *" = "ask";
              "*" = "allow";
            };
            external_directory = {
              "*" = "ask";
              "~/.config/opencode/skills/*" = "allow";
              "/tmp/*" = "allow";
              "/nix/store/*" = "allow";
            };
          };

          formatter = {
            nixpkgs-fmt = {
              command = [
                "nixpkgs-fmt"
                "$FILE"
              ];
              extensions = [ ".nix" ];
            };
          };

          lsp = false;

          compaction = {
            auto = true;
            prune = true;
            reserved = 5000;
          };

          watcher = {
            ignore = [
              "result"
              "result-*"
              ".direnv/**"
              "node_modules/**"
              ".git/**"
            ];
          };

          plugin = [
            "oh-my-opencode"
          ];

          instructions = [
            "~/.config/opencode/AGENTS.md"
          ];

          command = {
            test = {
              template = "Run the full test suite with coverage and show failures.";
              description = "Run tests with coverage";
            };
            review = {
              template = "Review the current changes for bugs, security issues, and code quality.";
              description = "Code review";
            };
            nix = {
              template = "Check the NixOS configuration for errors and evaluate the build.";
              description = "NixOS config check";
            };
          };

          agent = {
            code-reviewer = {
              description = "Reviews code for best practices and potential issues";
              prompt = "You are a code reviewer. Focus on security, performance, and maintainability.";
              tools = {
                write = false;
                edit = false;
              };
            };
            nix-expert = {
              description = "Expert in NixOS, Nix flakes, and Nix package management";
              prompt = "You are a NixOS expert. Help with Nix expressions, flakes, modules, and packaging.";
            };
          };

          subagent_depth = 1;

          attachment = {
            image = {
              auto_resize = true;
              max_width = 2000;
              max_height = 2000;
              max_base64_bytes = 5242880;
            };
          };
        };

        web = {
          enable = false;
          extraArgs = [
            "--hostname"
            "0.0.0.0"
            "--port"
            "4096"
          ];
          environmentFile = "/run/secrets/opencode_password_web";
        };

        tui = {
          theme = lib.mkDefault "tokyonight";
        };

        context = ''
          # Global Agent Instructions

          ## Output Style
          - Keep completion messages short and direct
          - After actions, report only a concise status and changed files

          ## Git Rules
          - Never auto-commit or auto-push
          - Generate commit messages; user runs commit/push
          - Use Conventional Commits format
          - Use `git diff` for comparing changes

          ## Code Style
          - Keep code formatted
          - Follow existing code style in the project
          - Apply KISS & DRY principles

          ## Code Testing
          - Any change must include tests
          - Prioritize positive & negative test cases

          ## NixOS
          - Run `nh os build` and 'nh home build' before committing NixOS changes
          - Use `nix eval` to test expressions
          - Prefer overlays for package modifications
          - Use nix-shell for temporary package installation
        '';
      };

      home.packages = with pkgs; [
        nixpkgs-fmt
      ];
    };
}
