#!/usr/bin/env sh

set -eu

prefix="/target"
admin="hub"

# expire user password (password must be set interactively on next login)
# TODO: implement this feature in a way that does not require `passwd` in the installer runtime
#passwd --delete "${admin}"
#passwd --expire "${admin}"

# custom configs
cp -a "/cdrom/configs/motd"        "${prefix}/etc/motd"
cp -a "/cdrom/configs/sshd_config" "${prefix}/etc/ssh/sshd_config"
cp -a "/cdrom/configs/bashrc.bash" "${prefix}/etc/skel/.bashrc"
cp -a "/cdrom/configs/bashrc.bash" "${prefix}/home/${admin}/.bashrc"

# authorize ssh keys
mkdir -p  "${prefix}/home/${admin}/.ssh"
chmod 700 "${prefix}/home/${admin}/.ssh"
cp -a "/cdrom/configs/authorized_keys" "${prefix}/home/${admin}/.ssh/authorized_keys"
chmod 644 "${prefix}/home/${admin}/.ssh/authorized_keys"

# reset user homedir owner
chown -R "1000:1000" "${prefix}/home/${admin}"
