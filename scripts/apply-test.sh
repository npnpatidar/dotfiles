#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild test --flake .#naresh
popd
