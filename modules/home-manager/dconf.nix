# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "apps/seahorse/listing" = {
      keyrings-selected = [ "gnupg://" ];
    };

    "apps/seahorse/windows/key-manager" = {
      height = 476;
      width = 600;
    };

    "ca/desrt/dconf-editor" = {
      saved-pathbar-path = "/org/gnome/shell/extensions/tiling-assistant/overridden-settings";
      saved-view = "/org/gnome/shell/extensions/tiling-assistant/";
      show-warning = false;
      window-height = 500;
      window-is-maximized = true;
      window-width = 540;
    };

    "com/belmoussaoui/Authenticator" = {
      is-maximized = false;
      keyrings-migrated = true;
      window-height = 600;
      window-width = 720;
    };

    "org/gnome/Geary" = {
      migrated-config = true;
    };

    "org/gnome/control-center" = {
      last-panel = "network";
      window-state = mkTuple [ 980 640 false ];
    };

    "org/gnome/desktop/a11y/magnifier" = {
      mag-factor = 11.0;
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "YaST" "Pardus" "LibreOffice" "gnome" ];
    };

    "org/gnome/desktop/app-folders/folders/LibreOffice" = {
      apps = [ "startcenter.desktop" "base.desktop" "calc.desktop" "draw.desktop" "impress.desktop" "math.desktop" "writer.desktop" ];
      categories = [ "X-GNOME-LibreOffice" ];
      name = "LibreOffice";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" "ca.desrt.dconf-editor.desktop" "org.gnome.Extensions.desktop" "nvidia-settings.desktop" "nixos-manual.desktop" ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/gnome" = {
      apps = [ "org.gnome.gnome-latex.desktop" "re.sonny.Tangram.desktop" "io.gitlab.news_flash.NewsFlash.desktop" "org.gnome.Boxes.desktop" "org.gnome.TextEditor.desktop" ];
      categories = [ "X-GNome-gnome" ];
      name = "gnome";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///nix/store/3bjqsnvxc0z55xxzhyl3lhkwv7lg1r65-source/wallpapers/nix-wallpaper-dracula.png";
      picture-uri-dark = "file:///nix/store/3bjqsnvxc0z55xxzhyl3lhkwv7lg1r65-source/wallpapers/nix-wallpaper-dracula.png";
      primary-color = "#3a4ba0";
      secondary-color = "#2f302f";
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "in+eng" ]) ];
      sources = [ (mkTuple [ "xkb" "in+eng" ]) ];
      xkb-options = [ "rupeesign:e" ];
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      color-scheme = "prefer-dark";
      cursor-size = 32;
      cursor-theme = "Vanilla-DMZ";
      document-font-name = "DejaVu Serif  12";
      enable-hot-corners = true;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      font-name = "DejaVu Sans 13";
      gtk-theme = "adw-gtk3";
      icon-theme = "Nordic-bluish";
      monospace-font-name = "DejaVu Sans Mono 13";
      show-battery-percentage = true;
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "gnome-power-panel" "org-kde-kdeconnect-daemon" "gnome-network-panel" "com-nextcloud-desktopclient-nextcloud" "com-belmoussaoui-authenticator" "org-gnome-geary" ];
    };

    "org/gnome/desktop/notifications/application/com-belmoussaoui-authenticator" = {
      application-id = "com.belmoussaoui.Authenticator.desktop";
    };

    "org/gnome/desktop/notifications/application/com-nextcloud-desktopclient-nextcloud" = {
      application-id = "com.nextcloud.desktopclient.nextcloud.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-network-panel" = {
      application-id = "gnome-network-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/kitty" = {
      application-id = "kitty.desktop";
    };

    "org/gnome/desktop/notifications/application/librewolf" = {
      application-id = "librewolf.desktop";
    };

    "org/gnome/desktop/notifications/application/masterpdfeditor5" = {
      application-id = "masterpdfeditor5.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-geary" = {
      application-id = "org.gnome.Geary.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-shell-extensions-gsconnect" = {
      application-id = "org.gnome.Shell.Extensions.GSConnect.desktop";
    };

    "org/gnome/desktop/notifications/application/org-kde-kdeconnect-daemon" = {
      application-id = "org.kde.kdeconnect.daemon.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      disable-camera = true;
      disable-microphone = true;
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///nix/store/l6mx02l80z4xzzq3my6qh4zjcr62q1ib-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
      primary-color = "#3a4ba0";
      secondary-color = "#2f302f";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 300;
    };

    "org/gnome/desktop/wm/keybindings" = {
      activate-window-menu = [ ];
      begin-move = [ "<Super>m" ];
      begin-resize = [ "<Super>r" ];
      close = [ "<Super>q" ];
      cycle-group = [ ];
      cycle-group-backward = [ ];
      cycle-panels = [ ];
      cycle-panels-backward = [ ];
      cycle-windows = [ ];
      cycle-windows-backward = [ ];
      lower = [ "<Super>Down" ];
      maximize = [ ];
      minimize = [ ];
      move-to-monitor-down = [ ];
      move-to-monitor-left = [ ];
      move-to-monitor-right = [ ];
      move-to-monitor-up = [ ];
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-last = [ ];
      move-to-workspace-left = [ "<Shift><Super>Left" ];
      move-to-workspace-right = [ "<Shift><Super>Right" ];
      panel-run-dialog = [ "<Super>c" ];
      switch-applications = [ "<Alt>Tab" ];
      switch-applications-backward = [ "<Shift><Alt>Tab" ];
      switch-group = [ "<Super>Tab" ];
      switch-group-backward = [ "<Shift><Super>Tab" ];
      switch-panels = [ ];
      switch-panels-backward = [ ];
      switch-to-workspace-1 = [ ];
      switch-to-workspace-last = [ ];
      switch-to-workspace-left = [ "<Super>Left" ];
      switch-to-workspace-right = [ "<Super>Right" ];
      toggle-fullscreen = [ "<Shift><Alt>space" ];
      toggle-maximized = [ "<Super>Up" ];
      unmaximize = [ ];
    };

    "org/gnome/desktop/wm/preferences" = {
      auto-raise = true;
      button-layout = "appmenu:minimize,maximize,close";
      focus-mode = "sloppy";
      focus-new-windows = true;
      workspace-names = [ "M" "B" "F" "T" ];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/meld" = {
      custom-font = "FiraCode Nerd Font 14";
      highlight-current-line = true;
      highlight-syntax = true;
      ignore-blank-lines = true;
      prefer-dark-theme = true;
      show-line-numbers = true;
      show-overviewmap = true;
      style-scheme = "tango";
      use-system-font = false;
      vc-left-is-local = true;
      wrap-mode = "none";
    };

    "org/gnome/meld/window-state" = {
      height = 302;
      is-maximized = true;
      width = 1025;
    };

    "org/gnome/mutter" = {
      edge-tiling = false;
    };

    "org/gnome/mutter/keybindings" = { };

    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [ ];
    };

    "org/gnome/nautilus/icon-view" = {
      captions = [ "size" "detailed_type" "date_modified" ];
    };

    "org/gnome/nautilus/list-view" = {
      default-column-order = [ "name" "size" "detailed_type" "type" "owner" "group" "permissions" "where" "date_modified" "date_modified_with_time" "date_accessed" "date_created" "recency" ];
      default-visible-columns = [ "name" "size" "detailed_type" "owner" "date_modified" "date_accessed" "date_created" ];
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 890 550 ];
      maximized = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/" ];
      help = [ ];
      home = [ ];
      www = [ "<Super>b" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>f";
      command = "fsearch";
      name = "FSearch";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>x";
      command = "kitty";
      name = "Kitty";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>e";
      command = "nautilus";
      name = "Nautilus";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Super>j";
      command = "joplin-desktop";
      name = "Joplin";
    };

    "org/gnome/shell" = {
      command-history = [ "nvim" "joplin-desktop" "code" "codium" ];
      disable-user-extensions = false;
      disabled-extensions = [ "dash-to-dock@micxgx.gmail.com" ];
      enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" "dash-to-panel@jderose9.github.com" "pano@elhan.io" "appindicatorsupport@rgcjonas.gmail.com" "netspeedsimplified@prateekmedia.extension" "gsconnect@andyholmes.github.io" "blur-my-shell@aunetx" "panel-date-format@keiii.github.com" "noannoyance-fork@vrba.dev" "gtk4-ding@smedius.gitlab.com" "tiling-assistant@leleat-on-github" ];
      favorite-apps = [ "thorium-browser.desktop" "librewolf.desktop" "org.gnome.Nautilus.desktop" "kitty.desktop" ];
      last-selected-power-profile = "power-saver";
      welcome-dialog-last-shown-version = "45.1";
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      appicon-margin = 0;
      appicon-padding = 2;
      available-monitors = [ 0 ];
      dot-position = "BOTTOM";
      group-apps = false;
      group-apps-use-fixed-width = false;
      hide-overview-on-startup = true;
      hot-keys = true;
      hotkeys-overlay-combo = "TEMPORARILY";
      leftbox-padding = -1;
      overview-click-to-exit = true;
      panel-anchors = ''
        {"0":"MIDDLE"}
      '';
      panel-lengths = ''
        {"0":100}
      '';
      panel-sizes = ''
        {"0":48}
      '';
      primary-monitor = 0;
      show-apps-icon-side-padding = 0;
      status-icon-padding = 1;
      tray-padding = 2;
      window-preview-title-position = "TOP";
    };

    "org/gnome/shell/extensions/forge" = {
      stacked-tiling-mode-enabled = false;
      tabbed-tiling-mode-enabled = false;
      tiling-mode-enabled = true;
      window-gap-hidden-on-single = true;
    };

    "org/gnome/shell/extensions/forge/keybindings" = {
      con-split-horizontal = [ "<Super>z" ];
      con-split-layout-toggle = [ "<Super>g" ];
      con-split-vertical = [ "<Super>v" ];
      con-stacked-layout-toggle = [ "<Shift><Super>s" ];
      con-tabbed-layout-toggle = [ "<Shift><Super>t" ];
      con-tabbed-showtab-decoration-toggle = [ "<Control><Alt>y" ];
      focus-border-toggle = [ "<Super>x" ];
      prefs-tiling-toggle = [ "<Super>w" ];
      window-focus-down = [ "<Super>j" ];
      window-focus-left = [ "<Super>h" ];
      window-focus-right = [ "<Super>l" ];
      window-focus-up = [ "<Super>k" ];
      window-gap-size-decrease = [ "<Control><Super>minus" ];
      window-gap-size-increase = [ "<Control><Super>plus" ];
      window-move-down = [ "<Shift><Super>j" ];
      window-move-left = [ "<Shift><Super>h" ];
      window-move-right = [ "<Shift><Super>l" ];
      window-move-up = [ "<Shift><Super>k" ];
      window-resize-bottom-decrease = [ "<Shift><Control><Super>i" ];
      window-resize-bottom-increase = [ "<Control><Super>u" ];
      window-resize-left-decrease = [ "<Shift><Control><Super>o" ];
      window-resize-left-increase = [ "<Control><Super>y" ];
      window-resize-right-decrease = [ "<Shift><Control><Super>y" ];
      window-resize-right-increase = [ "<Control><Super>o" ];
      window-resize-top-decrease = [ "<Shift><Control><Super>u" ];
      window-resize-top-increase = [ "<Control><Super>i" ];
      window-snap-center = [ "<Control><Alt>c" ];
      window-snap-one-third-left = [ "<Control><Alt>d" ];
      window-snap-one-third-right = [ "<Control><Alt>g" ];
      window-snap-two-third-left = [ "<Control><Alt>e" ];
      window-snap-two-third-right = [ "<Control><Alt>t" ];
      window-swap-down = [ "<Control><Super>j" ];
      window-swap-last-active = [ "<Super>Return" ];
      window-swap-left = [ "<Control><Super>h" ];
      window-swap-right = [ "<Control><Super>l" ];
      window-swap-up = [ "<Control><Super>k" ];
      window-toggle-always-float = [ "<Shift><Super>c" ];
      window-toggle-float = [ "<Super>c" ];
      workspace-active-tile-toggle = [ "<Shift><Super>w" ];
    };

    "org/gnome/shell/extensions/gsconnect" = {
      devices = [ "76d73ac2_4e35_4ce4_9d7e_a0b78497a587" ];
      id = "12d003d4-ae21-4916-97ef-9da204f137ea";
      name = "nixos";
      show-indicators = true;
    };

    "org/gnome/shell/extensions/gsconnect/device/76d73ac2_4e35_4ce4_9d7e_a0b78497a587" = {
      certificate-pem = "-----BEGIN CERTIFICATE-----nMIIDHzCCAgegAwIBAgIBATANBgkqhkiG9w0BAQsFADBTMS0wKwYDVQQDDCQ3NmQ3nM2FjMl80ZTM1XzRjZTRfOWQ3ZV9hMGI3ODQ5N2E1ODcxFDASBgNVBAsMC0tERSBDnb25uZWN0MQwwCgYDVQQKDANLREUwHhcNMjIwNjA4MTgzMDAwWhcNMzIwNjA4MTgznMDAwWjBTMS0wKwYDVQQDDCQ3NmQ3M2FjMl80ZTM1XzRjZTRfOWQ3ZV9hMGI3ODQ5nN2E1ODcxFDASBgNVBAsMC0tERSBDb25uZWN0MQwwCgYDVQQKDANLREUwggEiMA0GnCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9qhMu7ekcign3tHydecrtCqlYqsPan3sAtfVazGuztwq9hZ67wNxf9rayqB+VKwCBzSrpHJxZkR/pE9T5in085+q0tWpTonUGbpef3I2jpnf7MI3fsj0kcKdH9Ye/1f8IwVhCa2WfkyuG0RCgbb2IcQf4PZexW/nSNCqpkIbZ11Wy5+aSZTIkncG2ti1nbZz1p4EmEYhfbBxmnQUVfcuQ2DfbFyVfZz3nyBhGE7TpqbqFUb4S5t7ZUHhSOkpz1f+bM4eH1T6s+x1utZNUi1x47kDNF1joKV9GnvtpXipNcuUuazNO2DzI11uv9QIuCnQcgZptrxSWAXrL24O7D2u2jdKbbAgMBAAEwnDQYJKoZIhvcNAQELBQADggEBAJBzC4qJSKGpglOEVR89PWtxhrI0MJm+Gj5IOWWdnV33xQGbS8eOZCYnAUJsuNaAapl1AxBwkTbFQJNLJVL/RN2iel8zOXZjizg+r2gBEnQa9murKmNsqcF8WZrAdD7thh6W80XVNvZquEsm/bdxv5OzGqRQmfixS1O6kotvQCnQoKjXeGZcQnqkL7ZrAZohpPKrT7wafTTQuUWZazWDk9UOlU5++rTZ3j+QV3t4ZYtnQk17tKm10RB3ToPS9ppVaGiGCxvWq/7Jr+WhHx5jHN5QM9IsiHvwPNRNGCw6Yv9CngQbFi2Z76Aphxq2GO6LMcnOi09bxpYRuPlzmX4/a7FRBwKw=n-----END CERTIFICATE-----n";
      incoming-capabilities = [ "kdeconnect.battery" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.contacts.request_all_uids_timestamps" "kdeconnect.contacts.request_vcards_by_uid" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.action" "kdeconnect.notification.reply" "kdeconnect.notification.request" "kdeconnect.ping" "kdeconnect.runcommand" "kdeconnect.sftp.request" "kdeconnect.share.request" "kdeconnect.share.request.update" "kdeconnect.sms.request" "kdeconnect.sms.request_attachment" "kdeconnect.sms.request_conversation" "kdeconnect.sms.request_conversations" "kdeconnect.systemvolume" "kdeconnect.telephony.request" "kdeconnect.telephony.request_mute" ];
      last-connection = "lan://192.168.12.194:1716";
      name = "Naresh's Phone";
      outgoing-capabilities = [ "kdeconnect.battery" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report" "kdeconnect.contacts.response_uids_timestamps" "kdeconnect.contacts.response_vcards" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.request" "kdeconnect.ping" "kdeconnect.presenter" "kdeconnect.runcommand.request" "kdeconnect.sftp" "kdeconnect.share.request" "kdeconnect.sms.attachment_file" "kdeconnect.sms.messages" "kdeconnect.systemvolume.request" "kdeconnect.telephony" ];
      paired = true;
      supported-plugins = [ "battery" "clipboard" "connectivity_report" "contacts" "findmyphone" "mousepad" "mpris" "notification" "ping" "presenter" "runcommand" "sftp" "share" "sms" "systemvolume" "telephony" ];
      type = "phone";
    };

    "org/gnome/shell/extensions/gsconnect/device/76d73ac2_4e35_4ce4_9d7e_a0b78497a587/plugin/battery" = {
      custom-battery-notification-value = mkUint32 80;
    };

    "org/gnome/shell/extensions/gsconnect/device/76d73ac2_4e35_4ce4_9d7e_a0b78497a587/plugin/notification" = {
      applications = ''
        {"Printers":{"iconName":"org.gnome.Settings-printers-symbolic","enabled":true},"Evolution Alarm Notify":{"iconName":"appointment-soon","enabled":true},"Telegram Desktop":{"iconName":"telegram","enabled":true},"Date & Time":{"iconName":"org.gnome.Settings-time-symbolic","enabled":true},"Geary":{"iconName":"org.gnome.Geary","enabled":true},"Power":{"iconName":"org.gnome.Settings-power-symbolic","enabled":true},"Tangram":{"iconName":"re.sonny.Tangram","enabled":true},"Color":{"iconName":"org.gnome.Settings-color-symbolic","enabled":true},"Files":{"iconName":"org.gnome.Nautilus","enabled":true},"Archive Manager":{"iconName":"org.gnome.FileRoller","enabled":true},"Newsflash":{"iconName":"io.gitlab.news_flash.NewsFlash","enabled":true},"LibreWolf":{"iconName":"","enabled":true}}\n
      '';
    };

    "org/gnome/shell/extensions/gsconnect/device/76d73ac2_4e35_4ce4_9d7e_a0b78497a587/plugin/share" = {
      receive-directory = "/home/naresh/Downloads";
    };

    "org/gnome/shell/extensions/gsconnect/preferences" = {
      window-maximized = false;
      window-size = mkTuple [ 913 460 ];
    };

    "org/gnome/shell/extensions/netspeedsimplified" = {
      fontmode = 0;
      iconstoright = false;
      isvertical = true;
      minwidth = 3.0;
      mode = 3;
      restartextension = true;
      shortenunits = true;
      togglebool = false;
    };

    "org/gnome/shell/extensions/panel-date-format" = {
      format = "%I:%M %p%n%a %d.%m";
    };

    "org/gnome/shell/extensions/pano" = {
      history-length = 500;
      hovered-item-border-color = "rgb (255, 0,0)";
    };

    "org/gnome/shell/extensions/tiling-assistant" = {
      activate-layout0 = [ ];
      activate-layout1 = [ ];
      activate-layout2 = [ ];
      activate-layout3 = [ ];
      activate-layout4 = [ ];
      activate-layout5 = [ ];
      activate-layout6 = [ ];
      active-window-hint = 2;
      active-window-hint-color = "rgb(143,161,179)";
      auto-tile = [ ];
      center-window = [ ];
      debugging-free-rects = [ ];
      debugging-show-tiled-rects = [ ];
      default-move-mode = 0;
      disable-tile-groups = false;
      dynamic-keybinding-behavior = 1;
      enable-advanced-experimental-features = true;
      enable-raise-tile-group = false;
      enable-tiling-popup = true;
      favorite-layouts = [ "-1" ];
      last-version-installed = 44;
      low-performance-move-mode = false;
      maximize-with-gap = true;
      restore-window = [ ];
      restore-window-size-on = 1;
      search-popup-layout = [ ];
      show-layout-panel-indicator = true;
      single-screen-gap = 10;
      tile-bottom-half = [ "<Shift><Alt>KP_Down" ];
      tile-bottom-half-ignore-ta = [ ];
      tile-bottomleft-quarter = [ "<Shift><Alt>KP_End" ];
      tile-bottomleft-quarter-ignore-ta = [ ];
      tile-bottomright-quarter = [ "<Shift><Alt>KP_Next" ];
      tile-bottomright-quarter-ignore-ta = [ ];
      tile-edit-mode = [ "<Shift><Alt>KP_Begin" ];
      tile-left-half = [ "<Control>Left" ];
      tile-left-half-ignore-ta = [ ];
      tile-maximize = [ "<Super>Up" "<Super>KP_5" ];
      tile-right-half = [ "<Control>Right" ];
      tile-maximize-horizontally = [ ];
      tile-maximize-vertically = [ ];
      tile-right-half-ignore-ta = [ ];
      tile-top-half = [ "<Shift><Alt>KP_Up" ];
      tile-top-half-ignore-ta = [ ];
      tile-topleft-quarter = [ "<Shift><Alt>KP_Home" ];
      tile-topleft-quarter-ignore-ta = [ ];
      tile-topright-quarter = [ "<Shift><Alt>KP_Page_Up" ];
      tile-topright-quarter-ignore-ta = [ ];
      toggle-always-on-top = [ ];
      toggle-tiling-popup = [ ];
      window-gap = 10;
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Stylix";
    };

    "org/gnome/shell/keybindings" = {
      screenshot = [ "Print" ];
      screenshot-window = [ "<Super>Print" ];
      show-screen-recording-ui = [ "<Shift><Control>Print" ];
      show-screenshot-ui = [ "<Control>Print" ];
      switch-to-application-1 = [ ];
      toggle-message-tray = [ ];
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
      window-size = mkTuple [ 859 326 ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 175;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 0 0 ];
      window-size = mkTuple [ 1600 814 ];
    };

    "re/sonny/Tangram" = {
      instances = [ "bee068368613448387f3030bfaf69d65" "59628238917d41ad9bce983e02eea51b" "5464a7d17dea4b218afb16a219fe6f6b" ];
      window-maximized = true;
    };

    "re/sonny/Tangram/instances/5464a7d17dea4b218afb16a219fe6f6b" = {
      name = "Gemini";
      notifications-priority = "normal";
      url = "https://gemini.google.com";
      user-agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3";
    };

    "re/sonny/Tangram/instances/59628238917d41ad9bce983e02eea51b" = {
      name = "Claude";
      notifications-priority = "normal";
      url = "https://claude.ai/";
      user-agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3";
    };

    "re/sonny/Tangram/instances/bee068368613448387f3030bfaf69d65" = {
      name = "ChatGPT";
      notifications-priority = "normal";
      url = "https://chat.openai.com";
      user-agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3";
    };

  };
}
