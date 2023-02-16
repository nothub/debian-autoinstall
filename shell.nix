#!/usr/bin/env -S nix-shell --pure
let url = "https://github.com/NixOS/nixpkgs/archive/545c7a31e5dedea4a6d372712a18e00ce097d462.tar.gz";
in { pkgs ? import (fetchTarball url) { } }:
with pkgs; mkShell {
  nativeBuildInputs = [
    cacert
    coreutils
    curl
    gnupg
    xorriso
  ];
}
