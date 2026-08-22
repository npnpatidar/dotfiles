_: {
  flake.homeModules.pi-coding-agent =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.hm.dag) entryAfter;
      opencodeKeyFile = config.sops.secrets.opencode_api_key.path;
      nvidiaKeyFile = config.sops.secrets.nvidia_api_key.path;
      mistralKeyFile = config.sops.secrets.mistral_api_key.path;
    in
    {
      options.programs.pi-coding-agent = {
        sudoAskpass = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Install the pi sudo wrapper/askpass. Disable on headless hosts to allow normal interactive sudo.";
        };
      };

      config = {
        sops = {
          secrets = {
            opencode_api_key = {
              mode = "0600";
            };
            nvidia_api_key = {
              mode = "0600";
            };
            mistral_api_key = {
              mode = "0600";
            };
          };
        };

        home = {
          activation.setOpenCodeZenAuth = entryAfter [ "writeBoundary" ] ''
            mkdir -p "${config.home.homeDirectory}/.pi/agent"
            # Build auth.json from any available sops-managed keys (opencode, nvidia, mistral)
            tmp="${config.home.homeDirectory}/.pi/agent/auth.json.tmp"
            rm -f "$tmp"
            echo "{" > "$tmp"
            first=1
            if [ -f "${opencodeKeyFile}" ]; then
              printf '%s  "opencode": { "type": "api_key", "key": "%s" }' "$([ "$first" -eq 1 ] && echo "" || echo ",")" "$(cat ${opencodeKeyFile})" >> "$tmp"
              first=0
            fi
            if [ -f "${nvidiaKeyFile}" ]; then
              printf '%s  "nvidia": { "type": "api_key", "key": "%s" }' "$([ "$first" -eq 1 ] && echo "" || echo ",")" "$(cat ${nvidiaKeyFile})" >> "$tmp"
              first=0
            fi
            if [ -f "${mistralKeyFile}" ]; then
              printf '%s  "mistral": { "type": "api_key", "key": "%s" }' "$([ "$first" -eq 1 ] && echo "" || echo ",")" "$(cat ${mistralKeyFile})" >> "$tmp"
              first=0
            fi
            echo "" >> "$tmp"
            echo "}" >> "$tmp"
            if [ "$first" -eq 0 ]; then
              mv "$tmp" "${config.home.homeDirectory}/.pi/agent/auth.json"
              chmod 600 "${config.home.homeDirectory}/.pi/agent/auth.json"
            else
              rm -f "$tmp"
            fi
          '';

          sessionVariables = {
            PI_SKIP_VERSION_CHECK = "1";
          };

          file = {
            # pi-web-access resolves its config dir via XDG_CONFIG_HOME (~/.config/pi),
            # NOT ~/.pi — writing here is what actually disables the search curator.
            ".config/pi/web-search.json".text = builtins.toJSON {
              searxngBaseUrl = "http://alma.n:8056";
              commands.curator = false;
              autoOpenBrowser = false;
              ssrf = {
                allowRanges = [ "127.0.0.1/32" ];
              };
            };

            # Interactive question tool (options + free-text input) for the agent
            ".pi/agent/extensions/question.ts".source = ./pi-question.ts;

            # Managed herdr sub-agents: main agent gains the `subagent` tool
            # (spawns pi sub-agents in named herdr tabs with self-awareness,
            # non-recursion, single-task, report-and-terminate lifecycle);
            # sub-agent instances get report/note tools and no spawn tool.
            ".pi/agent/extensions/herdr-subagents" = {
              source = ./pi-subagents;
              recursive = true;
            };

            # sudo wrapper + askpass: the passwordless allowlist keeps NOPASSWD
            # paths (systemctl subcommands, nixos-rebuild) prompt-free; any other
            # sudo command pops a GUI password dialog on the user's desktop
            # (zenity, pinned store path) via `sudo -A`. The password is read by
            # sudo from the askpass's stdout over an internal pipe, so it never
            # reaches the agent's transcript, model context, tool output, the
            # TUI, or any file. Both files live in the Nix store (immutable —
            # the agent cannot tamper with them).
            ".local/bin/sudo" = lib.mkIf config.programs.pi-coding-agent.sudoAskpass {
              source = ./pi-sudo.sh;
              executable = true;
            };
            ".pi/agent/sudo-askpass.sh" = lib.mkIf config.programs.pi-coding-agent.sudoAskpass {
              text = ''
                #!/bin/sh
                # pi sudo askpass — run by `sudo -A` (see ~/.local/bin/sudo).
                # sudo captures this script's stdout as the password, so the
                # password is only ever written to stdout — an internal pipe read
                # by sudo. Prompting happens in a GUI dialog on the user's
                # desktop; nothing is written to any file.
                #
                # No display (headless hosts like alma): we must NOT print
                # anything to stdout (sudo would retry empty passwords 3x).
                # Exit non-zero with a clear message so sudo aborts and the
                # agent knows to extend the NOPASSWD allowlist instead.
                set -u

                ZENITY=${lib.escapeShellArg "${pkgs.zenity}/bin/zenity"}

                if [ -n "''${WAYLAND_DISPLAY:-}''${DISPLAY:-}" ] && [ -x "$ZENITY" ]; then
                  pw=$("$ZENITY" --password --title="pi needs the sudo password for $(id -un)" 2>/dev/null) || pw=
                  if [ -n "''${pw:-}" ]; then
                    printf '%s\n' "$pw"
                    exit 0
                  fi
                  echo "pi-askpass: no password entered — sudo cancelled" >&2
                  exit 1
                fi

                echo "pi-askpass: headless host — no interactive password path. Add this command to the NOPASSWD allowlist (modules/system/users.nix) or run it yourself." >&2
                exit 1
              '';
              executable = true;
            };

            # Custom footer: show actual context tokens (e.g. 48.2k/200k) instead of only percent
            ".pi/agent/extensions/footer.ts".source = ./pi-footer.ts;

          };
        };

        programs.pi-coding-agent = {
          enable = true;
          extraPackages = [
            pkgs.nodejs
            pkgs.bun
            pkgs.python3Minimal
          ];
          settings = {
            defaultProvider = "opencode";
            defaultModel = "opencode/x-preview-f-free";
            # enabledModels = [ "*free*" ];
            defaultThinkingLevel = "medium";
            theme = "dark";
            enableInstallTelemetry = false;
            packages = [
              "npm:pi-web-access"
              "git:github.com/md-riaz/omniroute-pi-ext-integration"
            ];

            compaction = {
              enabled = true;
              reserveTokens = 16384;
              keepRecentTokens = 20000;
            };
            retry = {
              enabled = true;
              maxRetries = 3;
            };
          };
          context = ''
            # Global Agent Instructions

            ## Output Style
            - Keep completion messages short and direct
            - After actions, report only a concise status and changed files

            ## Asking the User
            - When you need the user to choose between options or confirm something, use the `question` tool (options list + free-text) instead of asking in chat. The dialog renders in the TUI with selectable options.
            - Provide 2-5 concrete options; include a free-text option only via the tool's built-in "Type something." entry.
            - Only fall back to plain chat questions when the tool is unavailable (non-TUI mode).

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

            ## Service Management
            - User services: `systemctl --user <start|stop|restart|status|reload> <service>` — no sudo needed
            - System services: `sudo systemctl <start|stop|restart|status|reload> <service>` — passwordless sudo is configured for exactly these subcommands; anything else (enable, kill, reboot, ...) will be denied

            ## Sudo & Passwords
            - `sudo` is wrapped (~/.local/bin/sudo): allowlisted commands (systemctl subcommands, nixos-rebuild) never prompt; any other sudo command pops a GUI password dialog on the user's desktop, which only the user can fill. The password never enters your context, tool output, or any file — do not attempt to obtain it any other way.
            - On headless hosts (alma) there is no dialog: non-allowlisted sudo fails with a clear error. Do not retry it; tell the user what command needs sudo so they can extend the NOPASSWD allowlist (modules/system/users.nix) or run it themselves.
            - NEVER type, echo, pipe (`-S`), store, or write a password anywhere.

            ## Subagent Usage
            - The agent may autonomously decide to use subagents for tasks that would benefit from parallel execution, such as independent web searches, file operations, or build processes, without requiring explicit user request.
            - Subagents are managed with self-awareness to avoid recursion and report results upon completion.

            ## Project Instructions
            - Pi loads `AGENTS.md` from the current directory (and parents) at startup. Follow the project's `AGENTS.md` for project-specific workflows and commands.
          '';
        };
      };
    };
}
