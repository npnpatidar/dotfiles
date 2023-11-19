# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs,... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  # Enable experimental Features
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    # networking.useDHCP = true;
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  };


  # nvidia support 
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;

    prime = {
      # 	offload =                            # run program as nvidia-offload  glxgears
      # 		{
      # 			enable = true;
      # 			enableOffloadCmd = true;
      #  };
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };


  # specialisation = {      #special on-the-go mode which  enable offload mode 
  # 	on-the-go.configuration = {      
  # 		system.nixos.tags = [ "on-the-go" ];
  # 		hardware.nvidia = {
  # 			prime.offload.enable = lib.mkForce true;
  # 			prime.offload.enableOffloadCmd = lib.mkForce true;
  # 			prime.sync.enable = lib.mkForce false;
  # 	 };
  # 	};
  # };


  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Syncthign Settings
  services = {
    syncthing = {
      enable = true;
      user = "naresh";
      dataDir = "/home/naresh/Data/Sync_M_L/";
      configDir = "/home/naresh/.config/syncthing";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings.devices = {
        "RMX3312" = { id = "TYHX2SD-7KN5PCE-DMUV7F6-T5I22IU-5XJNC2A-JUAWJCK-M74C276-U6PNGAA"; };
        #  "device2" = { id = "DEVICE-ID-GOES-HERE"; };
      };
      settings.folders = {
        "knuao-1ygcm" = {
          # Name of folder in Syncthing, also the folder ID
          path = "/home/naresh/Documents"; # Which folder to add to Syncthing
          devices = [ "RMX3312" ]; # Which devices to share the folder with
        };
        "tpz2c-x9q93" = {
          path = "/home/naresh/Data/Sync_M_L";
          devices = [ "RMX3312" ];
        };
        "7snbs-p6fiq" = {
          path = "/home/naresh/Data/Sync_M_L_C";
          devices = [ "RMX3312" ];
        };
      };
    };
  };


  # Adguard DNS 
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      server_names = [ "adguard-dns-doh" ];
    };
  };




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
  services.xserver.xkbOptions = "rupeesign:e";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    gwenview
    okular
    oxygen
    khelpcenter
    plasma-browser-integration
    print-manager
    ark
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # enable this in KDE
  };

  # Enable Gnome Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  # environment.gnome.excludePackages = (with pkgs; [
  # 	gnome-photos
  # 	gnome-tour
  # 	gnome-text-editor
  # 	xterm
  # ]) ++ (with pkgs.gnome; [
  # 	cheese # webcam tool
  # 	gnome-music
  # 	gnome-terminal
  # 	gedit # text editor
  # 	epiphany # web browser
  # 	geary # email reader
  # 	evince # document viewer
  # 	gnome-characters
  # 	totem # video player
  # 	tali # poker game
  # 	iagno # go game
  # 	hitori # sudoku game
  # 	atomix # puzzle game
  # 	gnome-clocks
  # 	gnome-weather
  # 	gnome-maps
  # 	gnome-contacts
  # 	simple-scan
  # 	gnome-system-monitor
  # 	gnome-software
  # 	gnome-calendar
  # 	eog
  # ]);

  # Configure keymap in X11 and touchpad support
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    libinput = {
      enable = true;
      touchpad = {
        tappingDragLock = false;
        naturalScrolling = true;
      };
    };
  };

  # Enable Apple devices support
  services.usbmuxd.enable = true;


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

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.naresh = {
    isNormalUser = true;
    initialPassword = "naresh";
    description = "naresh";
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" ];
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    (import ./resources/appimage/thorium.nix { inherit pkgs; })

    #     appimage-run
    #     auto-cpufreq
    #     flatpak
    # nextdns
  ];

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

  #nextdns service 
  # services.nextdns = {
  # 	enable = true;
  # 	arguments = [ "-config" "ec4ca1" "-cache-size" "10MB" "-listen" "0.0.0.0:53" ];
  # };



  nix = {
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













  }
