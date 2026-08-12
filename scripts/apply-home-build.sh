#! /bin/sh
pushd ~/dotfiles
home-manager build --flake ~/dotfiles
popd
