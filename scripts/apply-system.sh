#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild switch --flake .#aspire7 --show-trace --option eval-cache false
popd
