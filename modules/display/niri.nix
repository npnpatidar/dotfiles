_:
let
  niriConfig = ''

    spawn-at-startup "noctalia"
    cursor {
      xcursor-size 24
      xcursor-theme "Adwaita"
    }

    prefer-no-csd

    hotkey-overlay {
      skip-at-startup
    }

    blur {
      passes 2
      offset 3.0
      noise 0.03
      saturation 1.0
    }

    window-rule {
      background-effect {
        blur true
        xray false
      }
    }

    window-rule {
      match app-id=r#"^(zen-beta|firefox)$"# title=r#"^Bitwarden"#
      open-floating true
    }

    window-rule {
      match app-id=r#"^(zen-beta|chromium|chromium-browser)$"#
      open-maximized true
    }

    window-rule {
      match title=r#"^Picture-in-Picture$"#
      open-floating true
      default-column-width { proportion 0.5; }
      default-window-height { proportion 0.5; }
    }

    window-rule {
      match app-id=r#"^zen.*$"# title=r#"^Library$"#
      open-floating true
      default-column-width { proportion 0.5; }
      default-window-height { proportion 0.5; }
    }

    window-rule {
      match app-id=r#"^xdg-desktop-portal$"#
      open-floating true
      default-column-width { proportion 0.5; }
      default-window-height { proportion 0.5; }
    }

    layer-rule {
      match namespace="^noctalia-(background|launcher-overlay|dock)-.*$"
      background-effect {
        blur true
        xray false
      }
    }

    layer-rule {
      match namespace="^noctalia-backdrop"
      place-within-backdrop true
    }

    layout {
      gaps 4
      border {
        width 2
        active-color "#7c3aed"
        inactive-color "#374151"
      }
      focus-ring { width 2; }
      preset-column-widths {
        proportion 0.2
        proportion 0.34
        proportion 0.5
        proportion 0.66
        proportion 0.8
        proportion 0.98
      }
    }

    input {
      keyboard {
        xkb { layout "us"; }
        numlock
      }
      touchpad {
        tap
        natural-scroll
      }
    }

    recent-windows {
      binds {
        Alt+Tab       { next-window; }
        Alt+Shift+Tab { previous-window; }
        Alt+grave       { next-window     filter="app-id"; }
        Alt+Shift+grave { previous-window filter="app-id"; }
      }
    }

    binds {
      Mod+Shift+Slash { show-hotkey-overlay; }

      Mod+Q { close-window; }
      Mod+F { maximize-column; }

      Mod+Return { spawn "kitty"; }
      Mod+T { spawn "kitty"; }
      Mod+B { spawn "zen-beta"; }
      Mod+Shift+B { spawn "acer-battery-toggle"; }
      Mod+E { spawn "nemo"; }
      Mod+S { spawn "noctalia" "msg" "panel-toggle" "launcher" "/fs "; }
      Mod+Y { spawn "kitty" "-e" "yazi"; }
      Mod+W { spawn "bitwarden"; }

      Mod+Escape { spawn "noctalia" "msg" "panel-toggle" "session"; }
      Mod+D { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
      Mod+Shift+Ctrl+S { spawn "voxtype" "record" "toggle"; }
      Mod+Space { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
      Mod+V { spawn "noctalia" "msg" "panel-toggle" "clipboard"; }
      Mod+Shift+S { spawn "bash" "-lc" "/home/naresh/.local/bin/dictation-toggle"; }
      Mod+Shift+Alt+S { spawn "bash" "-lc" "/home/naresh/.local/bin/hindi-dictation-toggle"; }
      Mod+x { spawn "noctalia" "msg" "theme-mode-toggle"; }

      Mod+Tab      { toggle-overview; }
      Mod+KP_5     { toggle-overview; }
      Mod+KP_Begin { toggle-overview; }

      Mod+Left       { focus-column-left; }
      Mod+Right      { focus-column-right; }
      Mod+Up         { focus-window-or-workspace-up; }
      Mod+Down       { focus-window-or-workspace-down; }
      Mod+KP_4       { focus-column-left; }
      Mod+KP_6       { focus-column-right; }
      Mod+KP_8       { focus-window-or-workspace-up; }
      Mod+KP_2       { focus-window-or-workspace-down; }
      Mod+KP_Left    { focus-column-left; }
      Mod+KP_Right   { focus-column-right; }
      Mod+KP_Up      { focus-window-or-workspace-up; }
      Mod+KP_Down    { focus-window-or-workspace-down; }

      Mod+Shift+Left       { move-column-left; }
      Mod+Shift+Right      { move-column-right; }
      Mod+Shift+Up         { move-window-up-or-to-workspace-up; }
      Mod+Shift+Down       { move-window-down-or-to-workspace-down; }
      Mod+Shift+KP_4       { move-column-left; }
      Mod+Shift+KP_8       { move-window-up-or-to-workspace-up; }
      Mod+Shift+KP_2       { move-window-down-or-to-workspace-down; }
      Mod+Shift+KP_6       { move-column-right; }
      Mod+Shift+KP_Left    { move-column-left; }
      Mod+Shift+KP_Right   { move-column-right; }
      Mod+Shift+KP_Up      { move-window-up-or-to-workspace-up; }
      Mod+Shift+KP_Down    { move-window-down-or-to-workspace-down; }

      Mod+Ctrl+Left       { focus-workspace-up; }
      Mod+Ctrl+Right      { focus-workspace-down; }
      Mod+Ctrl+KP_4       { focus-workspace-up; }
      Mod+Ctrl+KP_6       { focus-workspace-down; }
      Mod+Ctrl+KP_Left    { focus-workspace-up; }
      Mod+Ctrl+KP_Right   { focus-workspace-down; }

      Mod+Ctrl+Down       { move-window-to-workspace-down; }
      Mod+Ctrl+Up         { move-window-to-workspace-up; }
      Mod+Ctrl+KP_2       { move-window-to-workspace-down; }
      Mod+Ctrl+KP_8       { move-window-to-workspace-up; }
      Mod+Ctrl+KP_Down    { move-window-to-workspace-down; }
      Mod+Ctrl+KP_Up      { move-window-to-workspace-up; }

      Mod+KP_9       { focus-workspace-up; }
      Mod+KP_Prior   { focus-workspace-up; }
      Mod+KP_3       { focus-workspace-down; }
      Mod+KP_Next    { focus-workspace-down; }

      Mod+Shift+KP_9     { move-window-to-workspace-up; }
      Mod+Shift+KP_Prior { move-window-to-workspace-up; }
      Mod+Shift+KP_3     { move-window-to-workspace-down; }
      Mod+Shift+KP_Next  { move-window-to-workspace-down; }

      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }

      Mod+Shift+1 { move-window-to-workspace 1; }
      Mod+Shift+2 { move-window-to-workspace 2; }
      Mod+Shift+3 { move-window-to-workspace 3; }
      Mod+Shift+4 { move-window-to-workspace 4; }
      Mod+Shift+5 { move-window-to-workspace 5; }
      Mod+Shift+6 { move-window-to-workspace 6; }
      Mod+Shift+7 { move-window-to-workspace 7; }
      Mod+Shift+8 { move-window-to-workspace 8; }
      Mod+Shift+9 { move-window-to-workspace 9; }

      Mod+Alt+Right      { consume-or-expel-window-right; }
      Mod+Alt+Left       { consume-or-expel-window-left; }
      Mod+Alt+KP_6       { consume-or-expel-window-right; }
      Mod+Alt+KP_4       { consume-or-expel-window-left; }
      Mod+Alt+KP_Right   { consume-or-expel-window-right; }
      Mod+Alt+KP_Left    { consume-or-expel-window-left; }

      Mod+J       { toggle-window-floating; }
      Mod+Shift+J { switch-focus-between-floating-and-tiling; }

      Mod+R { switch-preset-column-width; }

      Mod+Equal        { set-column-width "+10%"; }
      Mod+Minus        { set-column-width "-10%"; }
      Mod+Shift+Equal  { set-window-height "+10%"; }
      Mod+Shift+Minus  { set-window-height "-10%"; }

      Mod+WheelScrollDown           { focus-column-right; }
      Mod+WheelScrollUp             { focus-column-left; }
      Mod+Shift+WheelScrollDown     { focus-workspace-down; }
      Mod+Shift+WheelScrollUp       { focus-workspace-up; }

      Ctrl+Alt+Delete { quit; }

      Print { screenshot-screen; }
      Ctrl+Print { screenshot; }
      Shift+Print { screenshot-screen write-to-disk=false; }
      Mod+Print { screenshot-window; }
      Mod+F1 { spawn "noctalia" "msg" "panel-toggle" "kenn/keybind-cheatsheet:cheatsheet"; }
      Mod+N { spawn "noctalia" "msg" "panel-toggle" "noctalia/notes:panel"; }



      XF86AudioRaiseVolume   allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
      XF86AudioLowerVolume   allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
      XF86AudioMute       allow-when-locked=true   { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
      XF86Launch6       { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
      XF86TouchpadOff   { spawn "sh" "-c" "notify-send 'Touchpad Off'"; }
      XF86TouchpadOn    { spawn "sh" "-c" "notify-send 'Touchpad On'"; }
      XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "s" "5%+"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "s" "5%-"; }
    }

    switch-events {
      lid-close {
        spawn "noctalia" "msg" "session" "lock-and-suspend";
      }
    }
  '';
in
{
  flake.nixosModules.niri = { inputs, pkgs, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    programs = {
      niri.enable = true;
      niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
    };

    environment.etc."niri/config.kdl".text = niriConfig;

    environment.systemPackages = with pkgs; [
      xwayland-satellite
      libnotify
      brightnessctl
      networkmanagerapplet
      pavucontrol
      pamixer
      wireplumber
      nemo-with-extensions
      grim
    ];
  };

  flake.homeModules.niri = { pkgs, inputs, ... }: {
    imports = [ inputs.niri.homeModules.niri ];

    programs.niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
    programs.niri.config = null;

    xdg = {
      portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = "gtk";
      };

      configFile."niri/config.kdl".text = niriConfig;
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
        xwayland-satellite
      ];

      sessionVariables = {
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_TYPE = "wayland";
        QT_QPA_PLATFORM = "wayland";
        GDK_BACKEND = "wayland";
        MOZ_ENABLE_WAYLAND = 1;
        NIXOS_OZONE_WL = "1";
      };
    };
  };
}
