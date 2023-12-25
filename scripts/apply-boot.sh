#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild boot --flake .#aspire7 --show-trace --option eval-cache false
popd

