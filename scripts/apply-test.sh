#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild test --flake .#$(hostname) --show-trace
popd
