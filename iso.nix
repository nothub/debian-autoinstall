#!/usr/bin/env nix-shell
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/7c9cc5a6e5d38010801741ac830a3f8fd667a7a0.tar.gz
#! nix-shell -p coreutils cacert curl gnupg xorriso
#! nix-shell -i bash --pure
#shellcheck shell=bash
./iso.sh
