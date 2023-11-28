#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild boot --flake .#naresh --show-trace --option eval-cache false
popd