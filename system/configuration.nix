# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import builtins.fetchTarball
      {
        url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
        sha256 = "sha256:0plki2yk02zcvyw7vynqhag6g1kl5qcicj8dvzfjx5p3p82yilkk";
      }
      {
        inherit pkgs;
      };
  };


  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./desktop_config/kde_config.nix
      # ./desktop_config/gnome_config.nix
      ./nvidia/nvidia.nix
      ./syncthing/syncthing.nix
      ./dns_config/dns_config.nix
      ./docker/docker.nix
    ];


  # Bootloader.

  boot = {

    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Enable experimental Features
  # nix = {
  #   package = pkgs.nixFlakes;
  #   extraOptions = "experimental-features = nix-command flakes";
  # };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    # networking.useDHCP = true;
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  };



  # Enable KDE Connect
  programs.kdeconnect.enable = true;
  programs.zsh.enable = true;




  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_IN";
    extraLocaleSettings = {
      LC_ADDRESS = "en_IN";
      LC_IDENTIFICATION = "en_IN";
      LC_MEASUREMENT = "en_IN";
      LC_MONETARY = "en_IN";
      LC_NAME = "en_IN";
      LC_NUMERIC = "en_IN";
      LC_PAPER = "en_IN";
      LC_TELEPHONE = "en_IN";
      LC_TIME = "en_IN";
    };
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        # fcitx5-qt5
        # fcitx5-qt6
        # fcitx5-qt4
        fcitx5-gtk
        fcitx5-m17n
      ];
    };


  };


  # Enable the X11 windowing system.
  # services.xserver.enable = true;



  # Configure keymap in X11 and touchpad support
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    xkbOptions = "rupeesign:e";
    libinput = {
      enable = true;
      touchpad = {
        tappingDragLock = false;
        naturalScrolling = true;
      };
    };
  };

  # Enable Apple devices support
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.naresh = {
    isNormalUser = true;
    initialPassword = "naresh";
    description = "naresh";
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "usbmux" ];
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
  };


  # environment.systemPackages = [ config.nur.repos.mic92.hello-nur ];
  # environment.systemPackages = with pkgs; [
  #     appimage-run
  #     auto-cpufreq
  #     flatpak
  # nextdns
  # systemd
  # usbmuxd
  # usbmuxd2

  #     (import ./appimage/thorium.nix { inherit pkgs; })
  # (import ./appimage/filen-desktop.nix { inherit pkgs; })
  # ];

  # List services that you want to enable:
  virtualisation.libvirtd.enable = true;

  # enable flatpak support
  services.flatpak.enable = true;
  services.dbus.enable = true;

  # Update nixos
  system.autoUpgrade = {
    #		enable = true;
    allowReboot = false;
    channel = "https://channels.nixos.org/nixos-unstable";
  };

  system.stateVersion = "23.05"; # Did you read the comment?




  nix = {

    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };

  #  videoDrivers = [ "modesetting" "nvidia" ];

  #     libinput.enable = true;
  # Tried to configure the touchpad here, but this crashes xserver:
  # inputClassSections = [''
  #   Identifier "Synaptics TM3471-020"
  #   Driver "libinput"
  #   MatchIsTouchpad "on"
  #   Device "/dev/input/event*"
  #   Option "AccelProfille"        "adaptive,flat"
  #   Option "ClickMethod"          "buttonareas,clickfinger"
  #   Option "DisableWhileTyping"   "true"
  #   Option "HorizontalScrolling"  "true"
  #   Option "LeftHanded"           "false"
  #   Option "MiddleEmulation"      "false"
  #   Option "NaturalScrolling"     "false"
  #   Option "ScrollMethod"         "twofinger,edge"
  #   Option "SendEventsMode"       "enabled"
  #   Option "Tapping"              "true"
  #   Option "TappingDrag"          "true"
  # ''];
  #   };


  # boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];


  #power management
  powerManagement.enable = true;
  services.thermald.enable = true;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };
  # services.tlp = {
  #       enable = true;
  #       settings = {
  #         CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #         CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

  #         CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #         CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

  #         CPU_MIN_PERF_ON_AC = 0;
  #         CPU_MAX_PERF_ON_AC = 100;
  #         CPU_MIN_PERF_ON_BAT = 0;
  #         CPU_MAX_PERF_ON_BAT = 20;
  #       };
  # };

}
