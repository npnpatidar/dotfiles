_: {
  flake.homeModules.alma-packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      nodejs
      kitty
      screen
      ghq
      btop
      nixfmt
      ouch
      python314Packages.huggingface-hub
      uv
      wireguard-tools
      dnsutils
      podman-compose
      llama-cpp
      ollama
      ketch
    ];
  };
}
