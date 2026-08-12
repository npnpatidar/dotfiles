#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild boot --flake .#$(hostname) --show-trace
popd

