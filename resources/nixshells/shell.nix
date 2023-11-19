{ pkgs ? import <nixpkgs> { } }:
# let
#   myscript = pkgs.writeShellScriptBin "foobar" ''
#     echo "Foobar" | figlet
#   '';
# in
pkgs.mkShell {
  name = "MyAwesomeShell";
  buildInputs = with pkgs;[
    # figlet
    # myscript
    nixFlakes
  ];

  # shellHook = ''
  #   echo "welcome to my awesome shell";
  # '';
  
}
