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
      EDITOR = "nano";
    };


    shellAliases = {
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
      ch = "function _curlcheat() { curl cheat.sh '$1' } _curlcheat";
      net = "sudo nethogs";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      zd = "zoxide add $(pwd)";
      doc_backup = "rclone sync /home/naresh/Data/Sync_M_L/Documents/ /home/naresh/.local/share/Cryptomator/mnt/EncryptedDocuments/   --verbose ";
      snc = "nano ~/dotfiles/system/configuration.nix";
      snh = "nano ~/dotfiles/users/naresh/home.nix";

      nos = "nix --extra-experimental-features 'nix-command flakes' search nixpkgs";
      note = "notepadqq";
      cnd = "codium ~/dotfiles";
      as = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-system.sh";
      ad = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-dry-build.sh";
      at = "cd ~/dotfiles/scripts && ~/dotfiles/scripts/apply-test.sh";
      lst = "lsd -lag --tree --group-directories-first --icon-theme unicode";
      lsa = "lsd  -lag --group-directories-first --icon-theme unicode";
      ls = "lsd  --icon-theme unicode ";

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
    source = ../power10k/.p10k.zsh;
    executable = true;
  };

# shell = pkgs.zsh;
}
