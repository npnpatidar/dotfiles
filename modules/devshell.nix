{ inputs, ... }:
{
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem = { config, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "dotfiles";
      inherit (config.pre-commit) shellHook;
      buildInputs = config.pre-commit.settings.enabledPackages;
      packages = with pkgs; [
        nixd
        nil
        git
      ];
    };
  };
}
