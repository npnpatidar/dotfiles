{ inputs, outputs, config, pkgs, ... }: {
  home.packages = with pkgs; [

    # Browsers 
    (import ../../pkgs/thorium.nix { inherit pkgs; })
    tangram


    # terminals
    alacritty

    # Communication
    # discord
    # telegram-desktop
    ferdium
    whatsapp-for-linux
    tutanota-desktop

    # Media
    # vlc
    # monophony

    #Coding
    # android-studio

    #Cloud Storage
    nextcloud-client
    syncthing
    (import ../../pkgs/filen-desktop.nix { inherit pkgs; })

    #Notes 
    gnome-text-editor

    #Documents
    libreoffice
    anki-bin
    obsidian
    stremio

    # lmstudio
    #mindmap 
    # freeplane

    #miscellaneious
    authenticator
    fsearch
    (import ../../pkgs/xdm-app.nix { inherit pkgs; })
    (import ../../pkgs/reader.nix { inherit pkgs; })
    # gnome.gnome-boxes
    newsflash
    localsend
    # bitwarden
    # inkscape-with-extensions
    ouch
    mathpix-snipping-tool
    # gpt4all
    # genymotion
    # qbittorrent
    git-lfs
    curl
    dos2unix
    screen
    peco #querying input
    jq
    yq
    nil #  nix LSP
    ripgrep #recursive search fs for a regex
    pstree
    zip
    unrar
    unzip
    w3m
    lazygit
    ghq
    btop
    ttop
    powertop
    poppler_utils #pdf conversions
    ttygif
    gifsicle
    rclone
    cryfs
    cht-sh
    perl536Packages.EmailOutlookMessage
    cz-cli
    zellij
    lm_sensors
    boxbuddy
    protonvpn-gui
    # jan
    # linkrec
    # zed-editor
    # nix-alien
    #   CLI Apps 
    ncdu
    mc
    onefetch
    yank
    nb
    nvitop
    dconf2nix
    # steam-run
    # python312Packages.howdoi
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
    screenfetch
    # rnix-lsp
    git
    git-crypt
    gnupg
    pinentry-gnome3
    wget
    nethogs
    fastfetch
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
    android-tools
    libimobiledevice
    ifuse
    tgpt
    direnv
    any-nix-shell
    nixpkgs-fmt
    nixfmt-classic
    cht-sh
    nix-init
    ripgrep
    distrobox
    wl-clipboard
    llama-cpp
    fzf
    cargo
    # nodejs_21
    gnumake
    tldr
    preload
    curl
    tmux
    rclone
    ffsend
    python312Packages.pudb
    python312Full
    ttyper
    gpg-tui
    termdbms
    bitwarden-cli
    lazydocker
    glow
    openssl
    russ
    tuifeed
    systemctl-tui
    newsboat # RSS Reader TUI
    podman-tui
    links2
    gorilla-cli
    trashy
    cheat
    ouch
    bandwhich
    entr # run arbitrary command when file changes
    # onlyoffice-bin_latest
    wpsoffice
    devenv
  ];


}
