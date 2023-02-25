#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

files_url="https://nothub.github.io/debian-autoinstall/files"
ssh_keys_url="https://github.com/nothub.keys"

# find user (from default userid)
user=$(id -u -n -- "1000")
user_home=$(getent passwd "${user}" | cut -d: -f6)

log="${user_home}/install.log"
touch "${log}"

echo "running post install commands" >>"${log}"

# expire user passwort (requires password to be defined on next login)
passwd --delete "${user}"
passwd --expire "${user}"

echo "password expired for user ${user}" >>"${log}"

# download some config
curl --location --output "/etc/ssh/sshd_config" "${files_url}/sshd_config"
curl --location --output "${user_home}/.bashrc" "${files_url}/bashrc"

echo "downloaded configs" >>"${log}"

# authorize ssh login
mkdir -p "${user_home}/.ssh"
chmod 700 "${user_home}/.ssh"
curl --location "${ssh_keys_url}" >"${user_home}/.ssh/authorized_keys"
chmod 644 "${user_home}/.ssh/authorized_keys"

echo "added ssh keys" >>"${log}"

# reset user homedir owner
chown -R "$(stat --format "%U:%G" "${user_home}")" "${user_home}"

echo "reset homedir perms for ${user}" >>"${log}"

echo "grep: $(command -v grep)" >>"${log}"
echo "shuf: $(command -v shuf)" >>"${log}"
echo "head: $(command -v head)" >>"${log}"
echo "tr: $(command -v tr)" >>"${log}"

# random art banner
rand() {
    local count
    if [[ -n $2 ]]; then count=$2; else count=1; fi
    echo -n "$1" | grep -Eo '\S{1}' | shuf | head --lines "$count"
}
buf+="$(rand "☀☄🌎🌑🚀🛰🛸" 3)"
buf+="$(for _ in {1..7}; do rand ",;'~*°✦⊚⊙⨀⋇"; done)"
buf+="$(for _ in {1..20}; do rand ".⋅∙⋆"; done)"
buf+="$(for _ in {1..750}; do echo -n " "; done)"
echo "${buf}" | grep -Eo '[^\n]{1}' | shuf | tr -d '\n' | grep -Eo '.{60}' >/etc/motd

echo "random art banner" >>"${log}"

# install nix
sh <(curl -L https://nixos.org/nix/install) --daemon

echo "install nix package manager" >>"${log}"
