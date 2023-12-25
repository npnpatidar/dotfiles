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
    vscodium-fhs
    android-studio
    meld # for git difftool

    #Cloud Storage
    nextcloud-client
    cryptomator
    syncthing
    (import ../../pkgs/filen-desktop.nix { inherit pkgs; })

    #Notes 
    qownnotes
    notepadqq


    #Documents
    libreoffice
    masterpdfeditor

    #Artificial Intelligence
    ollama
    # (import ./ollama { inherit pkgs; })

    #miscellaneious
    authenticator
    fsearch
    (import ../../pkgs/xdm-app.nix { inherit pkgs; })
    gnome.gnome-boxes


    #   CLI Apps 
    ncdu
    mc
    onefetch
    yank
    gh
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
    bat
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
    python3.pkgs.pip
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
    lazygit
    wl-clipboard
    llama-cpp
    fzf
    cargo
    nodejs_21
    gnumake
    tldr
  ];
}
