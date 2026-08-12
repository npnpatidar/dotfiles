_: {
  flake.nixosModules.noctalia = { inputs, pkgs, ... }: {
    imports = [ inputs.noctalia-greeter.nixosModules.default ];
    programs.noctalia-greeter = {
      enable = true;
      package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
      greeter-args = "--session niri";
      settings = {
        appearance.scheme = "Noctalia";
        session.default = "Niri";
        cursor = {
          theme = "Adwaita";
          size = 24;
        };
      };
    };
  };

  flake.homeModules.noctalia =
    {
      config,
      inputs,
      lib,
      ...
    }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia = {
        enable = true;
        systemd.enable = false;
        settings = {
          shell = {
            offline_mode = false;
            time_format = "{:%-I:%M %p}";
            date_format = "%A, %x";
            corner_radius_scale = 0.2;
            app_icon_colorize = false;
            clipboard_enabled = true;
            clipboard_history_max_entries = 10000;
            font_family = "DejaVu Sans";
            settings_show_advanced = false;
            polkit_agent = true;
            niri_overview_type_to_launch_enabled = true;
            screen_time_enabled = true;
            external_ip_enabled = true;
            greeter_sync = {
              auto_sync = false;
            };
            launcher = {
              categories = false;
            };
            panel = {
              transparency_mode = "glass";
              borders = true;
              shadow = true;
            };
            screen_corners = {
              enabled = true;
              size = 12;
            };
          };

          theme = {
            mode = "dark";
            source = "custom";
            builtin = "Catppuccin";
            custom_palette = lib.mkForce "nix-wallpaper-dracula-fs";
            wallpaper_scheme = "m3-monochrome";
            templates = {
              builtin_ids = [
                "alacritty"
                "btop"
                "gtk3"
                "gtk4"
                "kitty"
                "niri"
                "qt"
                "scroll"
              ];
              community_ids = [
                "opencode"
                "pi-agent"
                "pear-desktop"
                "zen-browser"
                "neovim"
                "obsidian"
                "vscode"
                "zed"
                "rofi"
                "zathura"
                "papirus-icons"
                "lazygit"
                "yazi"
              ];
            };
          };

          wallpaper = {
            enabled = true;
            default.path = config.stylix.image;
          };

          bar = {
            order = [ "main" ];
            main = {
              background_opacity = 0.20;
              margin_edge = 2;
              margin_ends = 100;
              margin_opposite_edge = 2;
              position = "top";
              thickness = 34;
              capsule = true;
              start = [
                "workspaces"
                "cpu"
                "ram"
                "net-rx"
                "net-tx"
                "media"
              ];
              center = [
                "clock-day"
                "clock-time"
                "clock-date"
              ];
              end = [
                "tray"
                "clipboard"
                "lock-keys"
                "notifications"
                "network"
                "bluetooth"
                "caffeine"
                "privacy"
                "control-center"
                "battery"
                "session"
              ];
            };
          };

          dock = {
            enabled = true;
            auto_hide = true;
            background_opacity = 1.0;
            reserve_space = false;
            position = "bottom";
            icon_size = 48;
            cross_axis_padding = 0;
            pinned = [
              "kitty"
              "org.gnome.Nemo"
              "dev.noctalia.Noctalia"
              "zen-beta"
            ];
            show_running = true;
            show_dots = true;
            magnification = true;
          };

          notification = {
            enable_daemon = true;
            position = "top_right";
            background_opacity = 1.0;
          };

          osd = {
            position = "top_center";
            orientation = "horizontal";
            background_opacity = 1.0;
            kinds = {
              volume = true;
              volume_output = true;
              volume_input = true;
              brightness = true;
              wifi = true;
              bluetooth = true;
              caffeine = true;
              dnd = true;
              lock_keys = true;
              keyboard_layout = true;
            };
          };

          lockscreen = {
            enabled = true;
            fingerprint = false;
            blurred_desktop = true;
            blur_intensity = 0.5;
          };

          backdrop = {
            enabled = true;
            blur_intensity = 0.3;
            tint_intensity = 0.3;
          };

          hot_corners = {
            enabled = true;
            bottom_left = {
              action = "window_switcher";
            };
            bottom_right = {
              action = "launcher";
            };
            top_right = {
              action = "control_center";
            };
          };

          calendar = {
            enabled = true;
            account.personal_rajedu = {
              calendars = [ ];
              name = "Personal";
              provider = "custom";
              server_url = "https://cal.${config.systemConstants.domain_name}";
              type = "caldav";
              username = "naresh@${config.systemConstants.domain_name}";
            };
          };

          lockscreen_widgets = {
            enabled = false;
            schema_version = 2;
            widget_order = [ "lockscreen-login-box@eDP-1" ];
            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = true;
            };
            widget."lockscreen-login-box@eDP-1" = {
              box_height = 0.0;
              box_width = 0.0;
              cx = 960.0;
              cy = 957.0;
              output = "eDP-1";
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                input_opacity = 1.0;
                input_radius = 6.0;
                show_login_button = true;
              };
            };
          };

          audio.enable_overdrive = false;

          nightlight = {
            enabled = false;
            temperature_day = 6500;
            temperature_night = 4000;
          };

          location.address = "Thakarda";

          system.monitor = {
            enabled = true;
            cpu_poll_seconds = 10.0;
            memory_poll_seconds = 10.0;
          };

          control_center = {
            sidebar = "full";
            sidebar_section = "full";
            width = 1000;
            shortcuts = [
              { type = "wifi"; }
              { type = "bluetooth"; }
              { type = "nightlight"; }
              { type = "dark_mode"; }
              { type = "screen_time"; }
            ];
          };

          desktop_widgets = {
            schema_version = 2;
            widget_order = [
              "desktop-widget-0000000000000002"
              "desktop-widget-0000000000000003"
            ];
            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = true;
            };
            widget = {
              "desktop-widget-0000000000000002" = {
                box_height = 544.0;
                box_width = 592.0;
                cx = 1608.0;
                cy = 796.0;
                output = "eDP-1";
                rotation = 0.0;
                type = "fancy_audio_visualizer";
                settings = {
                  background = false;
                };
              };
              "desktop-widget-0000000000000003" = {
                box_height = 464.0;
                box_width = 416.0;
                cx = 1712.0;
                cy = 244.0;
                output = "eDP-1";
                rotation = 0.0;
                type = "weather";
                settings = {
                  background_opacity = 0.0;
                  background_radius = 19;
                  forecast_days = 6;
                  show_forecast = true;
                };
              };
            };
          };

          plugins = {
            enabled = [
              "noctalia/notes"
              "kenn/keybind-cheatsheet"
              "naresh/live-file-search"
            ];
            source = [
              {
                name = "official";
                kind = "git";
                location = "https://github.com/noctalia-dev/official-plugins";
              }
              {
                name = "community";
                kind = "git";
                location = "https://github.com/noctalia-dev/community-plugins";
              }
              {
                name = "noctalia-plugins";
                kind = "git";
                location = "git@github.com:npnpatidar/noctalia-plugins.git";
              }
            ];
          };

          plugin_settings = {
            "kenn/keybind-cheatsheet" = {
              compositor = "niri";
              niri_config = "/home/naresh/.config/niri/config.kdl";
              show_actions = true;
            };
            "noctalia/notes" = {
              notes_dir = "/home/naresh/Data/Sync_M_L_I_C/Notes/Niri_Notes";
            };
            "naresh/live-file-search" = {
              search_folder = "/home/naresh";
              exclude_dirs = ".git, node_modules, .cache, .local/share/Trash, target, __pycache__, .npm, venv, .venv";
              max_results = 15;
            };
          };

          widget = {
            "workspaces" = {
              type = "workspaces";
              display = "id";
              hide_when_empty = true;
            };
            "clock-day" = {
              type = "clock";
              format = "{:%A}";
            };
            "clock-time" = {
              type = "clock";
              format = "{:%-I:%M}";
            };
            "clock-date" = {
              type = "clock";
              format = "{:%B %-d}";
            };
            "battery" = {
              type = "battery";
              show_label = true;
            };
            "battery-threshold" = {
              type = "damian-ds7/battery-threshold:battery-threshold";
            };
            "network" = {
              type = "network";
              show_label = true;
            };
            "cpu" = {
              type = "sysmon";
              stat = "cpu_usage";
              show_value = true;
            };
            "ram" = {
              type = "sysmon";
              stat = "ram_used";
              show_value = true;
            };
            "net-rx" = {
              type = "sysmon";
              stat = "net_rx";
              show_value = true;
            };
            "net-tx" = {
              type = "sysmon";
              stat = "net_tx";
              show_value = true;
            };
            "lock-keys" = {
              type = "lock_keys";
              display = "short";
              show_caps_lock = true;
              show_num_lock = true;
              show_scroll_lock = false;
              hide_when_off = true;
            };
            "media" = {
              type = "media";
              hide_when_no_media = true;
            };
            "caffeine" = {
              type = "caffeine";
            };
            "privacy" = {
              type = "privacy";
              hide_inactive = true;
            };
            "tray" = {
              match_adjacent_spacing = true;
            };
          };
        };
      };
    };
}
