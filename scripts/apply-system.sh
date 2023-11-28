#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild switch --flake .#naresh --show-trace
popd
