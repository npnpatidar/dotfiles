_: {
  flake.nixosModules.opencode =
    { config, ... }:
    {
      # Value is a systemd-style assignment, e.g.
      # `OPENCODE_SERVER_PASSWORD=...`. The opencode-server unit in the home
      # module copies the value into OpenCode's own service config.
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
          # The background service the TUI/CLI already uses (see
          # `opencode service status`). Proxying that same server keeps one set
          # of sessions, events, and permission prompts for the terminal, the
          # web UI, and the mobile app.
          proxyPass = "http://127.0.0.1:49374";
          # PTY terminals (`/api/pty/*/connect`) need the upgrade headers.
          proxyWebsockets = true;
          extraConfig = ''
            # `/api/event` is server-sent events, so don't buffer it.
            proxy_buffering off;
            proxy_cache off;
            proxy_read_timeout 1h;
            proxy_send_timeout 1h;
            # Image and file attachments are uploaded through this endpoint.
            client_max_body_size 50m;
          '';
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
          autoshare = false;
          default_agent = "build";

          # Restrict providers to OpenCode Go, NVIDIA and the OpenCode Console.
          # Deny-all first, then explicit allows (ordered statements, later
          # allow overrides deny).
          policies = [
            {
              action = "provider.use";
              resource = "*";
              effect = "deny";
            }
            {
              action = "provider.use";
              resource = "opencode-go";
              effect = "allow";
            }
            {
              action = "provider.use";
              resource = "nvidia";
              effect = "allow";
            }
            {
              action = "provider.use";
              resource = "opencode";
              effect = "allow";
            }
          ];

          # Console catalog drifts; regenerate this snapshot with:
          #   curl -s https://opencode.ai/inference/v1/models | python3 -c '...disable non-free...'
          # (see git history for the snippet)
          providers.opencode.models = builtins.fromJSON (builtins.readFile ./opencode-console-models.json);

          share = "manual";

          # `browse`: lets agents drive the real Chromium browser via the
          # OpenCode Browse extension (see pkgs/browse.nix).
          mcp.servers.browse = {
            type = "local";
            command = [
              "browse"
              "mcp"
            ];
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

        # The terminal and the app must talk to the same server, otherwise
        # sessions and live events do not line up. That server is OpenCode's
        # own background service (used by the TUI/CLI), exposed through nginx,
        # so no separate `opencode serve` unit is declared here.
        web.enable = false;

        # OpenCode 2 no longer reads tui.json; it uses cli.json, which the app
        # manages itself. Stylix still sets programs.opencode.tui, which only
        # produces a Home Manager warning on OpenCode 2, so clear it here.
        tui = lib.mkForce { };

        context = ''
          # Global Agent Instructions

          ## Output Style
          - Keep completion messages short and direct
          - After actions, report only a concise status and changed files

          ## Locale
          - Time zone is Asia/Kolkata (IST, UTC+05:30) — render all times/dates in IST
          - Use Indian English spelling and INR (₹) for currency
          - The system clock is already set to IST; never convert to other zones unless asked

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

          ## Notifications
          - The owner reads agent output on their phone via ntfy, not this chat
          - Send a notification when a task completes, fails, or needs the owner's input: `notify "title" "message" [priority] [topic] [tags]`
          - Priority 1=min 2=low 3=default 4=high 5=urgent; use 4+ only for failures or blocked-on-owner
          - Keep title under 10 words, message under 30 words
        '';
      };

      # Start the background service at boot, so the nginx vhost is reachable
      # from the phone without opening a terminal first. The password is kept in
      # sync with the sops secret, which is a `KEY=VALUE` line.
      systemd.user.services.opencode-server = {
        Unit = {
          Description = "OpenCode background server";
          After = [ "network.target" ];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "opencode-server-start";
              text = ''
                line=$(head -n1 /run/secrets/opencode_password_web)
                case "$line" in
                  *=*) want=${"$"}{line#*=} ;;
                  *) want=$line ;;
                esac

                have=$(${pkgs.opencode}/bin/opencode service get password 2>/dev/null || true)
                if [ -n "$want" ] && [ "$want" != "$have" ]; then
                  ${pkgs.opencode}/bin/opencode service set password "$want"
                fi

                exec ${pkgs.opencode}/bin/opencode service start
              '';
            }
          );
          # No ExecStop: the daemon belongs to OpenCode's own service manager,
          # so stopping this unit must not kill the server a TUI is using.
        };
        Install.WantedBy = [ "default.target" ];
      };

      # `/pricing` slash command (local plugin, versioned here rather than
      # living only in ~/.config/opencode/plugins). Single self-contained file:
      # the plugin loader cannot resolve relative imports and treats every
      # *.ts in the plugins root as a plugin.
      xdg.configFile."opencode/plugins/pricing.ts" = {
        source = ./opencode-plugin-pricing/pricing.ts;
      };
      xdg.configFile."opencode/pricing-usage.py" = {
        source = ./opencode-plugin-pricing/usage.py;
      };

      home.packages = with pkgs; [
        nixpkgs-fmt
      ];
    };
}
