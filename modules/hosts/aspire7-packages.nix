_: {
  flake.nixosModules.aspire7-packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gparted
      uv
      cacert
    ];
  };
  flake.homeModules.aspire7-packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      ente-auth
      alacritty
      karere
      pdfarranger
      python313Packages.python-lsp-server
      python312Packages.rope
      python3Packages.jupyterlab
      conda
      (import ../../pkgs/xdm-app.nix { inherit pkgs; })
      localsend
      xdg-desktop-portal-gtk
      pandoc
      ffmpeg
      pstree
      zip
      unrar
      docker
      zig
      cachix
      nixd
      nixdoc
      cargo
      gnumake
      gcc.cc
      glibc
      docker-compose
      lazydocker
      unzip
      btop-cuda
      poppler-utils
      ttygif
      gocryptfs
      nvitop
      ntfs3g
      bitwarden-desktop
      p7zip
      android-tools
      libimobiledevice
      ifuse
      libGL
      glib
      d2
      jekyll
      bundler
      nodejs_latest
      pear-desktop
      # Binary tools from the llama.cpp overlay (CUDA build, matches home.llama.gpu)
    ];
  };
}
