#!/usr/bin/env nix-shell
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/7f5639fa3b68054ca0b062866dc62b22c3f11505.tar.gz
#! nix-shell -p coreutils cacert curl gnupg xorriso
#! nix-shell -i bash --pure
#shellcheck shell=bash
./iso.sh
