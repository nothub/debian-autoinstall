with import <nixpkgs> {};
mkShell {
  buildInputs = [
    cacert
    coreutils
    curl
    gnupg
    xorriso
  ];
}
