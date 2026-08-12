#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild dry-build --flake .#$(hostname) --show-trace
popd

