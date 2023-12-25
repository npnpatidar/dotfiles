#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild dry-build --flake .#aspire7 --show-trace --option eval-cache false
popd

