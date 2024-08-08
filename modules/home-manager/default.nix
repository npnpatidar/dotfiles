{ config, pkgs, ... }:
{
  imports = [
    ./kitty.nix
    ./vscode.nix
    ./zsh/zsh.nix
    ./librewolf.nix
    ./gnome_settings.nix
    ./neovim.nix
    ./ranger.nix
    ./git.nix
    ./bat.nix
    ./applications.nix
    ./geary.nix
    ./xdg.nix
    ./masterpdfeditor.nix
    ./cryptomator.nix
    ./stylix/stylix.nix
    ./latex.nix
    ./fcitx5/fcitx5.nix
    ./qutebrowser.nix
    ./tmux.nix
    ./yazi.nix
    ./zathura.nix
    ./sioyek.nix
    ./joplin.nix
    ./mpv.nix
    ./imv.nix
    ./newsboat.nix
    ./rclone.nix
    ./distrobox.nix
    ./firstinstall.nix
    ./flatpak.nix
    ./bash.nix
  ];

}
