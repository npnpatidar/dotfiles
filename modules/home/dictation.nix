_: {
  flake.homeModules.dictation =
    {
      pkgs,
      inputs,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      dictationPkg = inputs.dictation.packages.${system}.dictation;
      nerdDictationPkg = inputs.dictation.packages.${system}.nerd-dictation;
    in
    {
      home = {
        packages = [
          dictationPkg
          nerdDictationPkg
          pkgs.wtype
        ];

        # Punctuation/symbol replacement + trailing-space handling for
        # nerd-dictation (auto-loaded from ~/.config/nerd-dictation/). The
        # trailing space keeps consecutive phrases in --continuous mode from
        # being glued together (VOSK final results carry no trailing whitespace).
        file = {
          ".config/nerd-dictation/nerd-dictation.py" = {
            source = ./../../scripts/nerd-dictation/nerd-dictation.py;
          };

          # Toggle script: start English dictation if not running, stop it otherwise.
          ".local/bin/dictation-toggle" = {
            executable = true;
            text = ''
              #!/bin/sh
              if pgrep -f "nerd-dictation.*begin" > /dev/null; then
                exec dictation stop
              else
                exec dictation en --continuous
              fi
            '';
          };

          # Toggle script: start Hindi dictation if not running, stop it otherwise.
          ".local/bin/hindi-dictation-toggle" = {
            executable = true;
            text = ''
              #!/bin/sh
              if pgrep -f "nerd-dictation.*begin" > /dev/null; then
                exec dictation stop
              else
                exec dictation hi --continuous
              fi
            '';
          };
        };
      };
    };
}
