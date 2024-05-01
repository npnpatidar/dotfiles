{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.zsh;
  alias-abbr = {
    neofetch = "fastfetch";
    nix-clean = "nix-store --optimise && nix-store --gc && nix-collect-garbage -d";
    firstinstall = "bash ${config.home.homeDirectory}/.scripts/firstinstall.sh";
    yay = "distrobox enter --name arch -- yay";
    pacman = "distrobox enter --name arch -- sudo pacman";
    apt = "distrobox enter --name deb -- sudo apt ";
    a = "distrobox enter --name arch -- ";
    d = "distrobox enter --name deb -- ";
    nv = "nvitop --colorful";
    o = "xdg-open";
    services = "systemctl-tui";
    cd = "z";
    r = "ranger";
    rd = "rm -rf ";
    # nvim = "steam-run nvim";
    c = "clear";
    sn = "sudo nano";
    htop = "btop --utf-force";
    e = "exit";
    q = "exit";
    ti = "tgpt -i";
    mlc = "cd /home/naresh/Data/Sync_M_L_C && ls";
    ml = "cd /home/naresh/Data/Sync_M_L && ls";
    lc = "cd /home/naresh/Data/Sync_L_C && ls";
    nl = "cd /home/naresh/Data/Sync_N_Laptop && ls";
    mydoc = "cd /home/naresh/Data/Sync_M_L/Documents/MyDoc/ && ls";
    docs = "cd /home/naresh/Data/Sync_M_L/Documents/ && ls";
    ch = "cht.sh";
    net = "sudo nethogs";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    doc_backup = "rclone sync /home/naresh/Data/Sync_M_L/Documents/ /home/naresh/.local/share/Cryptomator/mnt/EncryptedDocuments/   --verbose ";
    code = "codium";
    nos = "nix --extra-experimental-features 'nix-command flakes' search nixpkgs";
    note = "gnome-text-editor";
    vnd = "nvim ~/dotfiles";
    vnn = "nvim ~/dotfiles/hosts/rmx3312/nix-on-droid.nix";
    ab = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-boot.sh";
    as = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-system.sh";
    ad = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-dry-build.sh";
    at = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-test.sh";
    au = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-users.sh";
    buildvm = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/create-vm.sh";
    runvm = "$(readlink -f ~/dotfiles/result/bin/run-nixos-vm)";
    vm = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/create-vm.sh  && $(readlink -f ~/dotfiles/result/bin/run-nixos-vm)";
    lsa = "ls -a";
    lsl = "ls -l";
    lsla = "lsl -a";
    ls = "eza -gh --group-directories-first --git --icons --color-scale all --hyperlink";
    list-gen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    delete-gen = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system";
    clear-boot = "sudo /run/current-system/bin/switch-to-configuration boot";
    arch = "distrobox enter arch";
    deb = "distrobox enter deb";
    git-merge-droid = "git checkout test && git pull origin test && git merge droid && git push origin test && git checkout droid";
    git-merge-test = "git checkout work && git pull origin work && git merge test && git push origin work && git checkout test";
    git-merge-work = "git checkout main && git pull origin main && git merge work && git push origin main && git checkout work";
    gdt = "meld .";
    fzf = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
    das = "cd ~/dotfiles && git pull origin droid && cd scripts && ./apply-droid.sh";
    uas = "cd ~/dotfiles && git add . && git commit -m 'auto droid' && git push origin droid && cd scripts && ./apply-droid.sh";
    tm = "tmux new-session -t $(basename $(pwd))";
    np = "nix-shell -p";
    nei = "nix-env -i";
    nee = "nix-env -e";
    y = "yazi";
    lg = "lazygit";
    ras = "yazi ~/Data/Sync_M_L_C/Study/RAS";
    js = "joplin sync && joplin e2ee decrypt";
    j = "joplin";
    zl = "zellij";
    # ssh = "kitty +kitten ssh";
  };


in
{
  options.modules.home-manager.zsh = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {
    # zsh settings
    # defaultUserShell = pkgs.zsh;
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      history = {
        share = true; # false -> every terminal has it's own history
        size = 9999999; # Number of history lines to keep.
        save = 9999999; # Number of history lines to save.
        ignoreDups = true; # Do not enter command lines into the history list if they are duplicates of the previous event.
        extended = true; # Save timestamp into the history file.
      };
      dotDir = ".config/zsh";
      sessionVariables = {
        EDITOR = "nvim";
      };
      oh-my-zsh = {
        enable = false;
        plugins = [
          "thefuck"
          # "git"
          "fzf"
          "colored-man-pages"
          "extract"
          "copybuffer"
          "sudo"
          # "ssh-agent"
          "bgnotify"
        ];
      };
      zsh-abbr = {
        enable = true;
        abbreviations = alias-abbr;
      };


      shellAliases = alias-abbr // {
        lst = "function _lt() { ls --tree --level=\${1:-2}; }; _lt";
        lsta = "function _lt() { lsa --tree --level=\${1:-2}; }; _lt";
        jln = ''jln_func() { if [ "$#" -eq 2 ]; then joplin use "$1" && joplin mknote "$2" && joplin edit "$2"; else joplin use "Terminal" && joplin mknote "$1" && joplin edit "$1"; fi }; jln_func'';
        ssh = "kitty +kitten ssh";
      };
      completionInit = ""; # speed up zsh start time

      # initExtraFirst = ''
      #   zmodload zsh/zprof
      # '';

      initExtra = ''
         # be more bashy
         # setopt interactive_comments bashautolist nobeep nomenucomplete \
         #        noautolist extended_glob

         ## include config generated via "p10k configure" manually;
         ## zplug cannot edit home manager's zshrc file.

         [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

         # findup () {
         #   # uses zsh extended globbing, https://unix.stackexchange.com/a/64164
         #   echo (../)#$1(:a)
         # }

        #  any-nix-shell zsh --info-right | source /dev/stdin
        

      '';
      zplug = {
        enable = true;
        plugins = [
          { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
        ];
      };

    };


    home.file.".p10k.zsh" = {
      source = ./.p10k.zsh;
      executable = true;
    };
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.hstr = {
      enable = false;
      enableZshIntegration = true;
    };
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
    programs.thefuck = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.carapace = {
      enable = true;
      enableZshIntegration = true;
    };
  };




}

