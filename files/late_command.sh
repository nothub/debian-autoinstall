#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

url="https://nothub.github.io/debian-autoinstall/files"

# find user name (there is just 1 dir in /home/ right now)
user=$(basename "$(find "/home" -maxdepth 1 -type d -wholename "/home/*")")
user_home="/home/${user}"

# expire user passwort -> requires password to be defined on next login
passwd --delete "${user}"
passwd --expire "${user}"

# download some config
curl --location --output "/etc/motd" "${url}/motd"
curl --location --output "/etc/ssh/sshd_config" "${url}/sshd_config"
curl --location --output "${user_home}/.bashrc" "${url}/bashrc"

# authorize ssh login
mkdir -p "${user_home}/.ssh"
chmod 700 "${user_home}/.ssh"
curl --location "https://github.com/nothub.keys" >"${user_home}/.ssh/authorized_keys"
chmod 644 "${user_home}/.ssh/authorized_keys"

# reset user homedir owner
chown -R "$(stat --format "%U:%G" "${user_home}")" "${user_home}"
