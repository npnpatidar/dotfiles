{ config, pkgs, ... }: {

  # zsh settings

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  # defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";

    sessionVariables = {
      EDITOR = "nvim";
    };


    shellAliases = {
      cd = "z";
     # nvim = "steam-run nvim";
      c = "clear";
      sn = "sudo nano";
      htop = "btop --utf-force";
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
      ch = "cht.sh";
      net = "sudo nethogs";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      zd = "zoxide add $(pwd)";
      doc_backup = "rclone sync /home/naresh/Data/Sync_M_L/Documents/ /home/naresh/.local/share/Cryptomator/mnt/EncryptedDocuments/   --verbose ";
      code = "codium";
      nos = "nix --extra-experimental-features 'nix-command flakes' search nixpkgs";
      note = "notepadqq";
      vnd = "nvim ~/dotfiles";
      ab = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-boot.sh";
      as = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-system.sh";
      ad = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-dry-build.sh";
      at = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-test.sh";
      vm = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/create-vm.sh";
      lsa = "ls -a";
      lsl = "ls -l";
      lsla = "lsl -a";
      lst = "function _lt() { ls --tree --level=\${1:-2}; }; _lt";
      lsta = "function _lt() { lsa --tree --level=\${1:-2}; }; _lt";
      ls = "eza -Fgh --group-directories-first --git --git-ignore --icons --color-scale all --hyperlink";
      list-gen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      delete-gen = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system";
      clear-boot = "sudo /run/current-system/bin/switch-to-configuration boot";
      arch = "distrobox enter arch";
      git-merge-test = "git checkout main && git pull origin main && git merge test && git push origin main && git checkout test";
      gdt = "meld .";
      fzf = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
    };

    completionInit = ""; # speed up zsh start time

    initExtraFirst = ''
      zmodload zsh/zprof
    '';

    initExtra = ''
      # be more bashy
      setopt interactive_comments bashautolist nobeep nomenucomplete \
             noautolist extended_glob

      ## include config generated via "p10k configure" manually;
      ## zplug cannot edit home manager's zshrc file.

      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      findup () {
        # uses zsh extended globbing, https://unix.stackexchange.com/a/64164
        echo (../)#$1(:a)
      }

      any-nix-shell zsh --info-right | source /dev/stdin
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

  # shell = pkgs.zsh;
}

