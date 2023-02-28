#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo "A" >> INSTALL.LOG

files_url="https://nothub.github.io/debian-autoinstall/files"
ssh_keys_url="https://github.com/nothub.keys"

echo "B" >> INSTALL.LOG

# find user (from default userid)
user=$(id -u -n -- "1000")
user_home=$(getent passwd "${user}" | cut -d: -f6)

echo "C" >> INSTALL.LOG

# expire user passwort (requires password to be defined on next login)
passwd --delete "${user}"
passwd --expire "${user}"

echo "D" >> INSTALL.LOG

# download some configs
curl -fslo "/etc/ssh/sshd_config" "${files_url}/sshd_config"
curl -fslo "${user_home}/.bashrc" "${files_url}/bashrc"

echo "E" >> INSTALL.LOG

# motd banner
curl -fslo "/etc/motd" "${files_url}/motd"

echo "F" >> INSTALL.LOG

# authorize ssh login
mkdir -p "${user_home}/.ssh"
chmod 700 "${user_home}/.ssh"
curl -fslo "${user_home}/.ssh/authorized_keys" "${ssh_keys_url}"
chmod 644 "${user_home}/.ssh/authorized_keys"

echo "G" >> INSTALL.LOG

# reset user homedir owner
chown -R "$(stat --format "%U:%G" "${user_home}")" "${user_home}"

echo "H" >> INSTALL.LOG

# install docker
curl -fsl https://get.docker.com | sh -s

echo "I" >> INSTALL.LOG

# install nix
sh <(curl -fsl https://nixos.org/nix/install) --daemon

echo "J" >> INSTALL.LOG
