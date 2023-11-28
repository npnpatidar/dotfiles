#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild boot --flake .#naresh --show-trace
popd