#! /bin/sh
pushd ~/dotfiles
sudo nixos-rebuild test --flake .#aspire7 --show-trace --option eval-cache false
popd
