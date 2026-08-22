# Umbriel is a wlroots-based compositor from noctalia-dev.
# This module mirrors modules/display/niri.nix: same keybinds, layout,
# window/layer rules, and Noctalia integration expressed in Umbriel's
# TOML config (https://docs.noctalia.dev/umbriel/).
#
# Notes on the niri -> umbriel mapping:
# - Mod+Q close / Mod+F maximize are redefined here (umbriel defaults differ).
# - niri's per-window height binds have no equivalent (scrolling layout has no height presets).
# - Alt+Tab app-filtered switching (niri recent-windows) and lid-close switch-events
#   have no umbriel equivalent; Noctalia handles session actions instead.
let
  umbrielConfig = {
    include.files = [ ];

    general = {
      autostart = [ "noctalia" ];
      xwayland = true;
      # niri: hotkey-overlay { skip-at-startup; }
      show_cheatsheet = false;
      focus_on_activate = false;
    };

    appearance = {
      prefer_no_csd = true;
      border_width = 2;
      corner_radius = 10;
      border_focused = "#7c3aed";
      border_unfocused = "#374151";
      blur = {
        enabled = true;
        passes = 2;
        radius = 3;
        noise = 0.03;
        saturation = 1.0;
      };
    };

    layout = {
      mode = "scrolling";
      gap = 4;
      width_presets = [
        0.2
        0.34
        0.5
        0.66
        0.8
        0.98
      ];
      scrolling.default_width_fraction = 0.5;
      scrolling.center_underfull_strip = true;
    };

    input = {
      keyboard = {
        layout = "us";
        repeat_rate = 25;
        repeat_delay = 600;
      };
      touchpad = {
        tap = true;
        natural_scroll = true;
      };
      cursor = {
        theme = "Adwaita";
        size = 24;
      };
    };

    # Mirrors niri window-rule entries. app_id/title are regexes.
    window_rule = [
      {
        match.app_id = "^(zen-beta|firefox)$";
        match.title = "^Bitwarden";
        default_floating = true;
      }
      {
        match.app_id = "^(zen-beta|chromium|chromium-browser)$";
        default_maximize = true;
      }
      {
        match.title = "^Picture-in-Picture$";
        default_floating = true;
      }
      {
        match.app_id = "^zen.*$";
        match.title = "^Library$";
        default_floating = true;
      }
      {
        match.app_id = "^xdg-desktop-portal$";
        default_floating = true;
      }
      # Required by umbriel for its own UIs (share picker) and Noctalia settings.
      {
        match.app_id = "^dev.noctalia.Noctalia$";
        default_floating = true;
        default_size = [
          1020
          900
        ];
      }
      {
        match.app_id = "^dev.noctalia.UmbrielSharePicker$";
        default_floating = true;
        default_size = [
          800
          600
        ];
      }
    ];

    layer_rule = [
      {
        match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|launcher-overlay|desktop-widget-.+)$";
        blur = true;
        blur_ignore_alpha = 0.5;
      }
    ];

    keybinds = {
      # niri: Mod+Shift+Slash { show-hotkey-overlay; }
      "Mod+Shift+Slash" = "cheatsheet-toggle";

      # Windows
      "Mod+Q" = "window-close";
      "Mod+F" = "window-toggle-maximize"; # niri: maximize-column
      "Mod+J" = "window-toggle-floating";
      # no umbriel equivalent for niri's switch-focus-between-floating-and-tiling (Mod+Shift+J)

      # Launchers
      "Mod+Return" = "spawn:kitty";
      "Mod+T" = "spawn:kitty";
      "Mod+B" = "spawn:zen-beta";
      "Mod+Shift+B" = "spawn:acer-battery-toggle";
      "Mod+E" = "spawn:nemo";
      "Mod+S" = "spawn:noctalia msg panel-toggle launcher /fs";
      "Mod+Y" = "spawn:kitty -e yazi";
      "Mod+W" = "spawn:bitwarden";

      # Noctalia panels
      "Mod+Escape" = "spawn:noctalia msg panel-toggle session";
      "Mod+D" = "spawn:noctalia msg panel-toggle launcher";
      "Mod+Space" = "spawn:noctalia msg panel-toggle launcher";
      "Mod+V" = "spawn:noctalia msg panel-toggle clipboard";
      "Mod+X" = "spawn:noctalia msg theme-mode-toggle";
      "Mod+Shift+Ctrl+S" = "spawn:voxtype record toggle";
      "Mod+Shift+S" = "spawn:bash -lc /home/naresh/.local/bin/dictation-toggle";
      "Mod+Shift+Alt+S" = "spawn:bash -lc /home/naresh/.local/bin/hindi-dictation-toggle";
      "Mod+F1" = "spawn:noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet";
      "Mod+N" = "spawn:noctalia msg panel-toggle noctalia/notes:panel";

      # Overview (niri: toggle-overview)
      "Mod+Tab" = "overview-toggle";
      "Mod+KP_5" = "overview-toggle";
      "Mod+KP_Begin" = "overview-toggle";

      # Focus
      "Mod+Left" = "window-focus-left";
      "Mod+Right" = "window-focus-right";
      "Mod+Up" = "window-focus-up"; # niri: focus-window-or-workspace-up
      "Mod+Down" = "window-focus-down";
      "Mod+KP_4" = "window-focus-left";
      "Mod+KP_6" = "window-focus-right";
      "Mod+KP_8" = "window-focus-up";
      "Mod+KP_2" = "window-focus-down";
      "Mod+KP_Left" = "window-focus-left";
      "Mod+KP_Right" = "window-focus-right";
      "Mod+KP_Up" = "window-focus-up";
      "Mod+KP_Down" = "window-focus-down";

      # Move windows/columns
      "Mod+Shift+Left" = "column-move-left";
      "Mod+Shift+Right" = "column-move-right";
      "Mod+Shift+Up" = "window-move-up"; # niri: move-window-up-or-to-workspace-up
      "Mod+Shift+Down" = "window-move-down";
      "Mod+Shift+KP_4" = "column-move-left";
      "Mod+Shift+KP_8" = "window-move-up";
      "Mod+Shift+KP_2" = "window-move-down";
      "Mod+Shift+KP_6" = "column-move-right";
      "Mod+Shift+KP_Left" = "column-move-left";
      "Mod+Shift+KP_Right" = "column-move-right";
      "Mod+Shift+KP_Up" = "window-move-up";
      "Mod+Shift+KP_Down" = "window-move-down";

      # Workspaces via Ctrl+arrows
      "Mod+Ctrl+Left" = "workspace-previous";
      "Mod+Ctrl+Right" = "workspace-next";
      "Mod+Ctrl+KP_4" = "workspace-previous";
      "Mod+Ctrl+KP_6" = "workspace-next";
      "Mod+Ctrl+KP_Left" = "workspace-previous";
      "Mod+Ctrl+KP_Right" = "workspace-next";

      "Mod+Ctrl+Down" = "window-move-to-workspace-next";
      "Mod+Ctrl+Up" = "window-move-to-workspace-previous";
      "Mod+Ctrl+KP_2" = "window-move-to-workspace-next";
      "Mod+Ctrl+KP_8" = "window-move-to-workspace-previous";
      "Mod+Ctrl+KP_Down" = "window-move-to-workspace-next";
      "Mod+Ctrl+KP_Up" = "window-move-to-workspace-previous";

      "Mod+KP_9" = "workspace-previous";
      "Mod+KP_Prior" = "workspace-previous";
      "Mod+KP_3" = "workspace-next";
      "Mod+KP_Next" = "workspace-next";

      "Mod+Shift+KP_9" = "window-move-to-workspace-previous";
      "Mod+Shift+KP_Prior" = "window-move-to-workspace-previous";
      "Mod+Shift+KP_3" = "window-move-to-workspace-next";
      "Mod+Shift+KP_Next" = "window-move-to-workspace-next";

      # Numbered workspaces
      "Mod+1" = "workspace-switch:1";
      "Mod+2" = "workspace-switch:2";
      "Mod+3" = "workspace-switch:3";
      "Mod+4" = "workspace-switch:4";
      "Mod+5" = "workspace-switch:5";
      "Mod+6" = "workspace-switch:6";
      "Mod+7" = "workspace-switch:7";
      "Mod+8" = "workspace-switch:8";
      "Mod+9" = "workspace-switch:9";

      "Mod+Shift+1" = "window-move-to-workspace:1";
      "Mod+Shift+2" = "window-move-to-workspace:2";
      "Mod+Shift+3" = "window-move-to-workspace:3";
      "Mod+Shift+4" = "window-move-to-workspace:4";
      "Mod+Shift+5" = "window-move-to-workspace:5";
      "Mod+Shift+6" = "window-move-to-workspace:6";
      "Mod+Shift+7" = "window-move-to-workspace:7";
      "Mod+Shift+8" = "window-move-to-workspace:8";
      "Mod+Shift+9" = "window-move-to-workspace:9";

      # Column consume/expel
      "Mod+Alt+Right" = "window-expel-right";
      "Mod+Alt+Left" = "window-consume-left";
      "Mod+Alt+KP_6" = "window-expel-right";
      "Mod+Alt+KP_4" = "window-consume-left";
      "Mod+Alt+KP_Right" = "window-expel-right";
      "Mod+Alt+KP_Left" = "window-consume-left";

      # Widths
      "Mod+R" = "window-cycle-width"; # niri: switch-preset-column-width
      "Mod+Equal" = "window-modify-width:0.1";
      "Mod+Minus" = "window-modify-width:-0.1";
      # niri's set-window-height binds dropped: scrolling layout has no height control.

      # Scroll wheel navigation
      "Mod+WheelDown" = "window-focus-right";
      "Mod+WheelUp" = "window-focus-left";
      "Mod+Shift+WheelDown" = "workspace-next";
      "Mod+Shift+WheelUp" = "workspace-previous";

      # Session
      "Ctrl+Alt+Delete" = "session-quit";

      # Screenshots (via Noctalia; niri used built-in screenshot actions)
      "Print" = "spawn:noctalia msg screenshot-fullscreen";
      "Ctrl+Print" = "spawn:noctalia msg screenshot-region";
      # no window-scoped screenshot command yet for Mod+Print

      # Media / brightness keys
      "XF86AudioRaiseVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      "XF86AudioLowerVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      "XF86AudioMute" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      "XF86Launch6" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      "XF86TouchpadOff" = "spawn:sh -c \"notify-send 'Touchpad Off'\"";
      "XF86TouchpadOn" = "spawn:sh -c \"notify-send 'Touchpad On'\"";
      "XF86MonBrightnessUp" = "spawn:brightnessctl s 5%+";
      "XF86MonBrightnessDown" = "spawn:brightnessctl s 5%-";
    };
  };
in
{
  flake.nixosModules.umbriel =
    { inputs, pkgs, ... }:
    {
      imports = [ inputs.umbriel.nixosModules.default ];

      programs.umbriel.enable = true;

      environment.systemPackages = with pkgs; [
        xwayland-satellite
        libnotify
        brightnessctl
        networkmanagerapplet
        pavucontrol
        pamixer
        wireplumber
        grim
      ];
    };

  flake.homeModules.umbriel =
    { inputs, pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      imports = [ inputs.umbriel.homeModules.default ];

      programs.umbriel = {
        enable = true;
        settings = umbrielConfig;
      };

      xdg = {
        portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            inputs.xdg-desktop-portal-umbriel.packages.${system}.default
          ];
          config.common.default = [
            "umbriel"
            "gtk"
          ];
        };
      };

      home = {
        packages = with pkgs; [
          libnotify
          wl-clipboard
          brightnessctl
          networkmanagerapplet
          pavucontrol
          pamixer
          wireplumber
          qt5.qtwayland
          qt6.qtwayland
        ];

        sessionVariables = {
          XDG_CURRENT_DESKTOP = "umbriel";
          XDG_SESSION_TYPE = "wayland";
          QT_QPA_PLATFORM = "wayland";
          GDK_BACKEND = "wayland";
          MOZ_ENABLE_WAYLAND = 1;
          NIXOS_OZONE_WL = "1";
        };
      };
    };
}
