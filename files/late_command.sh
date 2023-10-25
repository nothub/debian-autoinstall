#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

files_url="https://nothub.github.io/debian-autoinstall/files"
ssh_keys_url="https://github.com/nothub.keys"

# find user (from default userid)
user=$(id -u -n -- "1000")
user_home=$(getent passwd "${user}" | cut -d: -f6)

# expire user passwort (requires password to be defined on next login)
passwd --delete "${user}"
passwd --expire "${user}"

# download some configs
curl -fsSLo "/etc/ssh/sshd_config" "${files_url}/sshd_config"
curl -fsSLo "${user_home}/.bashrc" "${files_url}/bashrc.bash"

# motd banner
curl -fsSLo "/etc/motd" "${files_url}/motd"

# authorize ssh login
mkdir -p "${user_home}/.ssh"
chmod 700 "${user_home}/.ssh"
curl -fsSLo "${user_home}/.ssh/authorized_keys" "${ssh_keys_url}"
chmod 644 "${user_home}/.ssh/authorized_keys"

# reset user homedir owner
chown -R "$(stat --format "%U:%G" "${user_home}")" "${user_home}"

# install nix
sh <(curl -fsSL https://nixos.org/nix/install) --daemon
