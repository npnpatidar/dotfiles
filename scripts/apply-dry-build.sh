#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild dry-build --flake .#naresh --show-trace --option eval-cache false
popd