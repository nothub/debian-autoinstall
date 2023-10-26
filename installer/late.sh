#!/usr/bin/env sh

set -eu

prefix="/target"
admin="@USERNAME@"

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
