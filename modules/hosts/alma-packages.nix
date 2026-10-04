_: {
  flake.homeModules.alma-packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      nodejs
      kitty
      screen
      ghq
      btop
      nixfmt
      python314Packages.huggingface-hub
      uv
      wireguard-tools
      dnsutils
      podman-compose
    ];
  };
}
