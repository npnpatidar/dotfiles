#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild test --flake .#naresh --show-trace --option eval-cache false
popd
