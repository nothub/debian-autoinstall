#!/usr/bin/env sh

set -eu

prefix="/target"
admin="@USERNAME@"
hostname="@HOSTNAME@"
domain="@DOMAIN@"

if test "${hostname}" == "undefined"; then
    # generate hostname from mac addresses
    hostname="deb$(cat /sys/class/net/*/address | tr -d '\n' | sha256sum | head -c 5)"
    echo "${hostname}" >"${prefix}/etc/hostname"
    cat <<EOF >"${prefix}/etc/hosts"
127.0.0.1	localhost
127.0.1.1	${hostname}.${domain}	${hostname}

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
fi

# custom configs
cp -a "/cdrom/configs/bashrc.bash" "${prefix}/etc/skel/.bashrc"
cp -a "/cdrom/configs/bashrc.bash" "${prefix}/home/${admin}/.bashrc"
cp -a "/cdrom/configs/bashrc.bash" "${prefix}/root/.bashrc"
cp -a "/cdrom/configs/issue"       "${prefix}/etc/issue"
cp -a "/cdrom/configs/motd"        "${prefix}/etc/motd"
cp -a "/cdrom/configs/sshd_config" "${prefix}/etc/ssh/sshd_config"

# authorize ssh keys for root user
mkdir -p  "${prefix}/root/.ssh"
chmod 700 "${prefix}/root/.ssh"
cp -a "/cdrom/configs/authorized_keys" "${prefix}/root/.ssh/authorized_keys"
chmod 640 "${prefix}/root/.ssh/authorized_keys"
# authorize ssh keys for admin user
mkdir -p  "${prefix}/home/${admin}/.ssh"
chmod 700 "${prefix}/home/${admin}/.ssh"
cp -a "/cdrom/configs/authorized_keys" "${prefix}/home/${admin}/.ssh/authorized_keys"
chmod 640 "${prefix}/home/${admin}/.ssh/authorized_keys"

# reset user homedir owner
chown -R "1000:1000" "${prefix}/home/${admin}"
