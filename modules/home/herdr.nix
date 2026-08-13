# herdr — terminal workspace manager for AI coding agents (https://herdr.dev)
#
# Wraps home-manager's own `programs.herdr` module (enable, package, settings
# written to ~/.config/herdr/config.toml, plus an automatic
# `herdr server reload-config` on switch). This file pins a deliberate,
# tmux/zellij-style keybinding scheme (prefix f12), the catppuccin theme,
# and the UI/integration defaults we want.
#
# Values are written verbatim to config.toml via `pkgs.formats.toml`, so the
# key names below are herdr's own snake_case schema — every key is optional,
# and `herdr --default-config` prints the full annotated reference.
# Custom values can be extended here anytime (e.g. keys.command entries,
# ui.sidebar.rows, theme.custom color tokens, ...).
{
  flake.homeModules.herdr = _: {
    programs.herdr = {
      enable = true;
      settings = {
        # Config is fully managed by Nix, so skip the first-run onboarding
        # prompts (which would otherwise offer to rewrite this file).
        onboarding = false;

        # --- Theme --------------------------------------------------------
        theme = {
          name = "catppuccin";
          # Follow the host terminal's light/dark appearance and swap themes.
          auto_switch = true;
          dark_name = "catppuccin";
          light_name = "catppuccin-latte";
        };

        # --- Terminal -------------------------------------------------------
        terminal = {
          # Empty => $SHELL (zsh), then /bin/sh.
          default_shell = "";
          # auto | login | non_login
          shell_mode = "auto";
          # follow = inherit CWD from the source pane/workspace.
          # home/$HOME, current = herdr's process dir, or a fixed path.
          new_cwd = "follow";
        };

        # --- Updates ----------------------------------------------------------
        update = {
          # stable releases; "preview" opts into pre-release builds.
          channel = "stable";
          version_check = true;
          manifest_check = true;
        };

        # --- Keybindings (tmux/zellij-style, prefix = f12) -------------------
        keys = {
          prefix = "f12";

          # general
          help = "prefix+?";
          settings = "prefix+s";
          detach = "prefix+q";
          reload_config = "prefix+shift+r";
          open_notification_target = "prefix+o";

          # workspaces (prefix+[/] = tmux-style previous/next)
          workspace_picker = "prefix+w";
          goto = "prefix+g";
          new_workspace = "prefix+shift+n";
          new_worktree = "prefix+shift+g";
          rename_workspace = "prefix+,"; # tmux-style rename-window
          close_workspace = "prefix+&"; # tmux-style kill-window w/ confirm
          previous_workspace = "prefix+[";
          next_workspace = "prefix+]";
          switch_workspace = "prefix+shift+1..9";

          # tabs
          new_tab = "prefix+c";
          rename_tab = "prefix+shift+t";
          previous_tab = "prefix+p";
          next_tab = "prefix+n";
          close_tab = "prefix+shift+x";
          switch_tab = "prefix+1..9";

          # panes (vim/hjkl movement, tmux-style splits)
          focus_pane_left = "prefix+h";
          focus_pane_down = "prefix+j";
          focus_pane_up = "prefix+k";
          focus_pane_right = "prefix+l";
          cycle_pane_next = "prefix+tab";
          cycle_pane_previous = "prefix+shift+tab";
          split_vertical = "prefix+v";
          split_horizontal = "prefix+minus";
          close_pane = "prefix+x";
          rename_pane = "prefix+shift+p";
          zoom = "prefix+z";
          resize_mode = "prefix+r";
          edit_scrollback = "prefix+e";

          # sidebar
          toggle_sidebar = "prefix+b";

          # agent rows are unbound by default; e.g.:
          # previous_agent = "prefix+shift+[";
          # next_agent     = "prefix+shift+]";
          # focus_agent    = "prefix+alt+1..9";

          # Custom commands: type = "shell" (detached background), "pane"
          # (temporary pane that closes on exit) or "popup" (modal overlay).
          # Width/height accept terminal cells or percentages like "80%".
          command = [
            {
              key = "prefix+alt+g";
              type = "popup";
              command = "lazygit";
              width = "80%";
              height = "80%";
            }
            {
              key = "prefix+alt+b";
              type = "popup";
              command = "btop --force-utf";
              width = "60%";
              height = "60%";
            }
            {
              key = "prefix+alt+f";
              type = "popup";
              command = "yazi";
              width = "70%";
              height = "70%";
            }
          ];
        };

        # --- UI ----------------------------------------------------------------
        ui = {
          # Sidebar geometry (auto-scaled from workspace names around these)
          sidebar_width = 26;
          sidebar_min_width = 18;
          sidebar_max_width = 36;
          sidebar_start_collapsed = false;
          sidebar_collapsed_mode = "compact"; # compact rail | hidden

          # Mouse & cursor
          mouse_capture = true;
          copy_on_select = true;
          host_cursor = "auto"; # auto | native | drawn
          redraw_on_focus_gained = true;
          mouse_scroll_lines = 3;

          # Tabs/workspaces (create immediately with generated names, like zellij)
          confirm_close = true;
          prompt_new_tab_name = false;
          prompt_new_workspace_name = false;

          # Layout
          pane_borders = true;
          pane_gaps = true;
          show_agent_labels_on_pane_borders = true;
          hide_tab_bar_when_single_tab = true;
          agent_panel_sort = "priority"; # attention-queue order | "spaces"

          # Notifications & sound
          toast = {
            delivery = "herdr"; # off | herdr | terminal | system
            delay_seconds = 0; # immediate notifications
            herdr = {
              position = "top-right";
            };
            clipboard = {
              enabled = true;
              position = "bottom-center";
            };
          };
          sound.enabled = true;
        };

        # --- Session / remote --------------------------------------------------
        # Resume AI-agent panes into their native conversation sessions after a
        # server restart (requires official integrations reporting session refs).
        session.resume_agents_on_restore = true;
        # herdr manages the ssh config it uses for `herdr --remote`: includes
        # ~/.ssh/config first, adds keepalive fallbacks, multiplexes connections.
        remote.manage_ssh_config = true;

        # --- Advanced -------------------------------------------------------------
        # Max scrollback retained per pane terminal (matches Ghostty's default).
        advanced.scrollback_limit_bytes = 10000000;

        # Worktree storage for new_worktree/open_worktree (default below).
        # worktrees.directory = "~/.herdr/worktrees";

        # Experimental options, off by default; enable deliberately if needed.
        # experimental = {
        #   # allow launching herdr from inside a herdr-managed pane
        #   allow_nested = false;
        #   # kitty graphics rendering for attached clients
        #   kitty_graphics = false;
        #   # persist pane screen history across full server restarts
        #   pane_history = false;
        # };
      };
    };
  };
}
