_: {
  flake.nixosModules.acer-battery =
    { config, pkgs, ... }:
    let
      kernelPackages = config.boot.kernelPackages;
      acer-wmi-battery = kernelPackages.kernel.stdenv.mkDerivation {
        name = "acer-wmi-battery-${kernelPackages.kernel.version}";
        src = pkgs.fetchzip {
          url = "https://github.com/frederik-h/acer-wmi-battery/archive/9f90d75cc9237aeed7964622d10dbdf4d2c7b518.tar.gz";
          hash = "sha256-CyKRpE3cnhEIFHc4Hal2PQUW7cd5k8+55S4QdSqGvNI=";
        };
        nativeBuildInputs = kernelPackages.kernel.moduleBuildDependencies;
        buildPhase = ''
          make -C ${kernelPackages.kernel.dev}/lib/modules/${kernelPackages.kernel.modDirVersion}/build M=$PWD modules
        '';
        installPhase = ''
          install -D -m 644 acer-wmi-battery.ko "$out/lib/modules/${kernelPackages.kernel.modDirVersion}/misc/acer-wmi-battery.ko"
        '';
        enableParallelBuilding = true;
        meta = with pkgs.lib; {
          description = "Linux kernel driver for Acer battery health control";
          homepage = "https://github.com/frederik-h/acer-wmi-battery";
          license = licenses.gpl2Only;
          platforms = [ "x86_64-linux" ];
        };
      };
    in
    {
      boot = {
        extraModulePackages = [ acer-wmi-battery ];
        kernelModules = [ "acer-wmi-battery" ];
        extraModprobeConfig = ''
          options acer-wmi-battery enable_health_mode=1
        '';
      };

      security.sudo.extraRules = [
        {
          users = [ "naresh" ];
          commands = [
            {
              command = "${pkgs.systemd}/bin/systemctl start acer-battery-health-toggle";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      systemd.services.acer-battery-health-toggle = {
        description = "Toggle Acer battery health mode (charge limit ~80%)";
        serviceConfig.Type = "oneshot";
        script = ''
          HEALTH_SYSFS="/sys/bus/wmi/drivers/acer-wmi-battery/health_mode"
          if [ ! -f "$HEALTH_SYSFS" ]; then
            exit 1
          fi
          CURRENT=$(cat "$HEALTH_SYSFS")
          if [ "$CURRENT" = "1" ]; then
            echo 0 > "$HEALTH_SYSFS"
          else
            echo 1 > "$HEALTH_SYSFS"
          fi
        '';
      };

      environment.systemPackages = with pkgs; [
        (writeShellScriptBin "acer-battery-toggle" ''
          notify() { noctalia msg notification-show "$1" -- "$2" 2>/dev/null || true; }
          HEALTH_SYSFS="/sys/bus/wmi/drivers/acer-wmi-battery/health_mode"
          if [ ! -f "$HEALTH_SYSFS" ]; then
            notify "Battery Health" "Driver not loaded"
            exit 1
          fi
          sudo ${systemd}/bin/systemctl start acer-battery-health-toggle
          sleep 0.3
          NEW=$(cat "$HEALTH_SYSFS")
          if [ "$NEW" = "1" ]; then
            notify "Battery Health" "Enabled — charge limit ~80%"
          else
            notify "Battery Health" "Disabled — will charge to 100%"
          fi
        '')
      ];
    };
}
