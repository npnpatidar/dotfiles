_: {
  flake.nixosModules.power-management =
    { pkgs, ... }:
    {
      imports = [ (import ./acer-battery.nix { }).flake.nixosModules.acer-battery ];

      powerManagement = {
        enable = true;
        powertop.enable = true;
      };
      services = {
        thermald.enable = true;
        power-profiles-daemon.enable = false;
        upower.enable = true;
        auto-cpufreq.enable = true;
        auto-cpufreq.settings = {
          battery = {
            governor = "powersave";
            turbo = "never";
            energy_performance_preference = "power";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };

      boot.kernel.sysctl = {
        "vm.dirty_writeback_centisecs" = 1500;
        "vm.dirty_expire_centisecs" = 3000;
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 5;
        "kernel.nmi_watchdog" = 0;
      };

      environment.systemPackages = with pkgs; [ wlr-randr ];

      systemd.services.power-supply-handler = {
        # All power management techniques are employed only while the
        # battery is below 75%; otherwise the system runs at full performance.
        description = "Apply power management based on battery level (<75%)";
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [
          auto-cpufreq
          iw
          iproute2
          kmod
          wlr-randr
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          CAPACITY=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
          if [ -z "$CAPACITY" ]; then
            # No battery present: default to full performance.
            CAPACITY=100
          fi

          TOTAL_CPUS=$(nproc)
          HALF=$((TOTAL_CPUS / 2))
          IGPU_CARD="/sys/class/drm/card1"

          WIFI_IF=$(ls /sys/class/net/ 2>/dev/null | grep -E '^wl' | head -1)
          ETH_IF=$(ls /sys/class/net/ 2>/dev/null | grep -E '^en' | head -1)
          MONITOR="eDP-1"
          KITTY_CONF="/home/naresh/.config/kitty/power.conf"

          if [ "$CAPACITY" -ge 75 ]; then
            systemctl start immich-server immich-machine-learning  redis-immich|| true
            systemctl --user -M naresh@ start filen-desktop || true

            for ((i=1; i<TOTAL_CPUS; i++)); do
              [ -e "/sys/devices/system/cpu/cpu$i/online" ] && echo 1 > "/sys/devices/system/cpu/cpu$i/online" 2>/dev/null || true
            done

            [ -n "$ETH_IF" ] && ip link set "$ETH_IF" up 2>/dev/null || true
            [ -n "$WIFI_IF" ] && iw dev "$WIFI_IF" set txpower auto 2>/dev/null || true

            echo 0 > /sys/module/workqueue/parameters/power_efficient 2>/dev/null || true
            echo "balanced" > /sys/firmware/acpi/platform_profile 2>/dev/null || true
            echo 60 > /proc/sys/vm/swappiness 2>/dev/null || true
            echo 1 > /sys/module/snd_hda_intel/parameters/power_save 2>/dev/null || true

            cat /dev/null > "$KITTY_CONF" 2>/dev/null || true

            modprobe uvcvideo 2>/dev/null || true
            modprobe pcspkr joydev snd_hda_codec_hdmi 2>/dev/null || true
            echo 1300 > "$IGPU_CARD/gt_max_freq_mhz" 2>/dev/null || true
            echo 1 > /sys/bus/pci/rescan 2>/dev/null || true

            sudo -u naresh WAYLAND_DISPLAY=wayland-1 wlr-randr --output "$MONITOR" --on 2>/dev/null || true

            auto-cpufreq --force performance --turbo auto 2>/dev/null || true
          else
            systemctl stop immich-server immich-machine-learning redis-immich|| true
            systemctl --user -M naresh@ stop filen-desktop || true

            for ((i=HALF; i<TOTAL_CPUS; i++)); do
              [ -e "/sys/devices/system/cpu/cpu$i/online" ] && echo 0 > "/sys/devices/system/cpu/cpu$i/online" 2>/dev/null || true
            done

            [ -n "$ETH_IF" ] && ip link set "$ETH_IF" down 2>/dev/null || true
            [ -n "$WIFI_IF" ] && iw dev "$WIFI_IF" set txpower fixed 1000 2>/dev/null || true

            echo 10 > /proc/sys/vm/swappiness 2>/dev/null || true
            echo 10 > /sys/module/snd_hda_intel/parameters/power_save 2>/dev/null || true
            echo 1 > /sys/module/workqueue/parameters/power_efficient 2>/dev/null || true
            echo "low-power" > /sys/firmware/acpi/platform_profile 2>/dev/null || true

            printf '%s\n' 'background #000000' 'background_opacity 1.0' > "$KITTY_CONF" 2>/dev/null || true

            modprobe -r uvcvideo 2>/dev/null || true
            modprobe -r pcspkr joydev snd_hda_codec_hdmi 2>/dev/null || true
            echo 800 > /sys/class/drm/card0/gt_max_freq_mhz 2>/dev/null || true
            echo 800 > "$IGPU_CARD/gt_max_freq_mhz" 2>/dev/null || true
            [ -e /sys/block/nvme1n1/device/remove ] && echo 1 > /sys/block/nvme1n1/device/remove 2>/dev/null || true

            auto-cpufreq --force powersave --turbo never 2>/dev/null || true

            RES=$(sudo -u naresh WAYLAND_DISPLAY=wayland-1 wlr-randr 2>/dev/null | grep "$MONITOR" -A5 | grep -oP '\d+x\d+(?=@)' | head -1)
            [ -n "$RES" ] && sudo -u naresh WAYLAND_DISPLAY=wayland-1 wlr-randr --output "$MONITOR" --mode "''${RES}@60" 2>/dev/null || true
          fi
        '';
      };

      services.udev.extraRules = ''
        ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Battery", ENV{POWER_SUPPLY_STATUS}=="Charging", RUN+="${pkgs.systemd}/bin/systemctl --no-block start power-supply-handler.service"
        ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Battery", ENV{POWER_SUPPLY_STATUS}=="Discharging", RUN+="${pkgs.systemd}/bin/systemctl --no-block start power-supply-handler.service"
      '';

      # Re-evaluate periodically so the 75% threshold is honored even between
      # charging/discharging state changes (timer persists the oneshot unit).
      systemd.timers.power-supply-handler = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "3min";
          OnUnitActiveSec = "5min";
        };
      };
    };
}
