{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "naresh";
  home.homeDirectory = "/home/naresh";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };

  # imports = [ plasma-manager.homeManagerModules.plasma-manager ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    alacritty
    screenfetch
    konsole
    rnix-lsp
    ibus
    ibus-engines.m17n
    git
    git-crypt
    gnupg
    pinentry-qt
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ]; #) ++ ([(builtins.getFlake "github:pjones/plasma-manager")]);

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/naresh/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash.enable = true;
  programs.bash.shellAliases = {
    c = "clear";
    sn = "sudo nano";
    htop = "btop";
    h = "history | grep $1";
    rebash = " source ~/.bashrc";
    e = "exit";
    ti = "tgpt -i";
    mlc = "cd /home/naresh/Data/Sync_M_L_C && ls";
    ml = "cd /home/naresh/Data/Sync_M_L && ls";
    lc = "cd /home/naresh/Data/Sync_L_C && ls";
    nl = "cd /home/naresh/Data/Sync_N_Laptop && ls";
    mydoc = "cd /home/naresh/Data/Sync_M_L/Documents/MyDoc/ && ls";
    docs = "cd /home/naresh/Data/Sync_M_L/Documents/ && ls";
    ch = "function _curlcheat() { curl cheat.sh/'$1' } _curlcheat";
    net = "sudo nethogs";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    zd = "zoxide add '$(pwd)'";
    doc_backup = "rclone sync /home/naresh/Data/Sync_M_L/Documents/ /home/naresh/.local/share/Cryptomator/mnt/EncryptedDocuments/   --verbose ";
    snc = "nano ~/.dotfiles/system/configuration.nix";
    snm = "nano ~/.dotfiles/users/naresh/home.nix";
    snr = "sudo nixos-rebuild";
    nos = "nix --extra-experimental-features 'nix-command flakes' search nixpkgs";
    note = "notepadqq";
    cnd = "code ~/.dotfiles";
    as = "~/.dotfiles/apply-system.sh";
    au = "~/.dotfiles/apply-users.sh";
  };


  # programs.plasma = {
  #   enable = true;

  #   # Some high-level settings:
  #   workspace.clickItemTo = "select";

  #   hotkeys.commands."Launch Konsole" = {
  #     key = "Meta+Alt+K";
  #     command = "konsole";
  #   };

  #   # Some mid-level settings:
  #   shortcuts = {
  #     ksmserver = {
  #       "Lock Session" = [ "Screensaver" "Meta+Ctrl+Alt+L" ];
  #     };

  #     kwin = {
  #       "Expose" = "Meta+,";
  #       "Switch Window Down" = "Meta+J";
  #       "Switch Window Left" = "Meta+H";
  #       "Switch Window Right" = "Meta+L";
  #       "Switch Window Up" = "Meta+K";
  #     };
  #   };

  #   # A low-level setting:
  #   configFile."baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
  # };
}

