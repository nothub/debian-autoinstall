#!/usr/bin/env nix-shell
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/988cc958c57ce4350ec248d2d53087777f9e1949.tar.gz
#! nix-shell -p cacert coreutils curl gnupg xorriso
#! nix-shell -i bash --pure
#shellcheck shell=bash
./iso.sh
