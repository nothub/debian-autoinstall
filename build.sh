#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# TODO: flags
username="hub"
password="$(pwgen -ns 16 1)"
hostname="machine"
domain="hub.lol"
iso_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.2.0-amd64-netinst.iso"
signing_key="DA87E80D6294BE9B"

# download
iso_file=$(basename ${iso_url})
if [[ ! -f ${iso_file} ]]; then
    echo >&2 "Downloading iso image: ${iso_file}"
    curl --progress-bar --location --remote-name ${iso_url}
fi
curl --silent --location --remote-name "$(dirname ${iso_url})/SHA256SUMS"
curl --silent --location --remote-name "$(dirname ${iso_url})/SHA256SUMS.sign"

# verify
gpg --keyserver keyring.debian.org --recv "${signing_key}"
gpg --verify SHA256SUMS.sign SHA256SUMS
if ! sha256sum -c <<<"$(grep "${iso_file}" SHA256SUMS)"; then
    echo >&2 "Error: Checksum not matching for: ${iso_file}"
    exit 1
fi

workdir=$(mktemp --directory)

# unpack iso
xorriso \
    -osirrox on \
    -dev "${iso_file}" \
    -extract "/isolinux/isolinux.cfg" "${workdir}/isolinux.cfg" \
    -extract "/isolinux/adtxt.cfg" "${workdir}/adtxt.cfg"

# set default boot entry and parameters
sed -i "s#default vesamenu.c32#default auto#" "${workdir}/isolinux.cfg"
sed -i "s#auto=true#auto=true file=/cdrom/preseed.cfg#" "${workdir}/adtxt.cfg"

# admin user name
sed -i "s#admin=.*#admin=\"${username}\"#" "installer/late.sh"
# admin password
salt="$(pwgen -ns 16 1)"
hash="$(mkpasswd -m sha-512 -S "${salt}" "${password}")"
sed -i "s#d-i passwd/user-password-crypted password.*#d-i passwd/user-password-crypted password ${hash}#" "installer/preseed.cfg"

# hostname
sed -i "s#d-i netcfg/get_hostname string.*#d-i netcfg/get_hostname string ${hostname}#" "installer/preseed.cfg"
# domain
sed -i "s#d-i netcfg/get_domain string.*#d-i netcfg/get_domain string ${domain}#" "installer/preseed.cfg"

# repack iso
rm -f "${iso_file//.iso/-auto.iso}"
xorriso -indev "${iso_file}" \
    -map "${workdir}/isolinux.cfg" "/isolinux/isolinux.cfg" \
    -map "${workdir}/adtxt.cfg"    "/isolinux/adtxt.cfg" \
    -map "installer/preseed.cfg"   "/preseed.cfg" \
    -map "installer/late.sh"       "/late.sh" \
    -map "installer/splash.png"    "/isolinux/splash.png" \
    -map "configs/motd"            "/configs/motd" \
    -map "configs/sshd_config"     "/configs/sshd_config" \
    -map "configs/bashrc.bash"     "/configs/bashrc.bash" \
    -map "configs/authorized_keys" "/configs/authorized_keys" \
    -boot_image isolinux dir=/isolinux \
    -outdev "${iso_file//.iso/-auto.iso}"

rm -rf "${workdir}"

echo "host: ${hostname}.${domain}"
echo "user: ${username}"
echo "pass: ${password}"
