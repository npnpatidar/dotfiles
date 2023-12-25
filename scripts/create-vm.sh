#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild build-vm --flake .#aspire7 --show-trace --option eval-cache false
popd
