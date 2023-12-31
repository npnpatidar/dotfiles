#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild test --flake .#aspireM --show-trace --option eval-cache false
# home-manager switch --flake ~/dotfiles
popd
