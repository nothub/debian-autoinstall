with import <nixpkgs> {};
mkShell {
  buildInputs = [
    cacert
    coreutils
    curl
    xorriso
  ];
}
