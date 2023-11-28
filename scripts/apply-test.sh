#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild test --flake .#naresh --show-trace
popd
