_: {
  flake.homeModules.distrobox = _: {
    programs.distrobox = {
      enable = true;
      settings.containerManager = "podman";
      containers = {
        ubuntu = {
          entry = true;
          image = "quay.io/toolbx/ubuntu-toolbox:latest";
          additional_packages = "git eza fastfetch atuin zoxide neovim curl ";
        };
        arch = {
          entry = true;
          image = "quay.io/toolbx/arch-toolbox:latest";
          additional_packages = "git base-devel pacman fzf fastfetch atuin eza zoxide curl ";
          exported_bins = "";
          exported_apps = "";
          init_hooks = "cd ~ && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm";
        };
      };
    };
  };
}
