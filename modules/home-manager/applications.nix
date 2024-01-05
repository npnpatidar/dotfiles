{ inputs, outputs, config, pkgs, ... }: {
  home.packages = with pkgs; [


    # Fonts
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    # Browsers 
    (import ../../pkgs/thorium.nix { inherit pkgs; })
    tangram


    # terminals
    alacritty

    # Communication
    discord
    telegram-desktop
    ferdium
    whatsapp-for-linux
    tutanota-desktop

    # Media
    vlc
    feh


    #Coding
    # android-studio

    #Cloud Storage
    nextcloud-client
    syncthing
    (import ../../pkgs/filen-desktop.nix { inherit pkgs; })

    #Notes 
    qownnotes
    gnome-text-editor

    #Documents
    libreoffice

    #Artificial Intelligence
    ollama
    oterm
    # (import ./ollama { inherit pkgs; })

    #mindmap 
    freeplane

    #miscellaneious
    authenticator
    fsearch
    (import ../../pkgs/xdm-app.nix { inherit pkgs; })
    gnome.gnome-boxes
    newsflash
    # bitwarden


    #   CLI Apps 
    ncdu
    mc
    onefetch
    yank
    nb
    nvitop
    dconf2nix
    python311Packages.howdoi
    # steam-run
    gcc
    zig
    unzip
    fd
    tree-sitter
    comma
    fontconfig
    zlib
    appimage-run
    btop
    flatpak
    bash
    screenfetch
    rnix-lsp
    git
    git-crypt
    gnupg
    pinentry-gnome
    wget
    neofetch
    nethogs
    ntfs3g
    p7zip
    fuse-7z-ng
    rclone
    # scrcpy
    #   yt-dlp
    zoxide
    conda
    docker
    docker-compose
    xdg-desktop-portal-gtk
    python3Full
    android-tools
    libimobiledevice
    ifuse
    tgpt
    direnv
    any-nix-shell
    nixpkgs-fmt
    eza
    nixfmt
    cht-sh
    nix-init
    ripgrep
    distrobox
    wl-clipboard
    llama-cpp
    fzf
    cargo
    nodejs_21
    gnumake
    tldr
    preload
    thefuck
    curl
    rclone
    ffsend

  ];
}
