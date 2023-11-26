{ config, pkgs, ... }: {



  imports = [  
    ./plasma-manager.nix
    ./vscode.nix
    ./zsh/zsh.nix
  ];

  home.packages = with pkgs; [

    (import ./thorium.nix { inherit pkgs; })
    (import ./filen-desktop.nix { inherit pkgs; })

    ark
    appimage-run
    # auto-cpufreq
    flatpak
    # zsh
    # oh-my-zsh
    librewolf
    screenfetch
    konsole
    rnix-lsp
    # ibus
    # ibus-engines.m17n
    git
    git-crypt
    gnupg
    pinentry-qt
    wget
    authenticator
    # autojump
    # bash-completion
    # btop
    cryptomator
    ferdium
    fsearch

    #   kdeconnect
    libreoffice
    masterpdfeditor4
    neofetch
    nethogs
    ntfs3g
    p7zip
    fuse-7z-ng
    rclone
    # scrcpy
    syncthing
    #   yt-dlp
    thefuck
    vscodium-fhs
    vlc
    zoxide
    conda
    # spectacle
    docker
    docker-compose
    #  simplenote
    # joplin
    qemu
    # ventoy
    # starship


    feh
    python3.pkgs.pip
    xdg-desktop-portal-gtk

    nextcloud-client
    qownnotes
    python3Full

    notepadqq
    android-tools
    libimobiledevice
    ifuse
    # antidote
    tgpt
    #gnome packages 
    # gnome.adwaita-icon-theme
    gnome.gnome-boxes
    direnv
    any-nix-shell
    # zsh-autosuggestions
    # gnomeExtensions.appindicator
    lsd
    # fira-code
    # fira-code-symbols
    nixpkgs-fmt

  ];

}
