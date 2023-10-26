#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

usage() {
    echo "Usage: $0 [-u username] [-p password] [-n hostname] [-d domain] [-i iso_url] [-s sign_key] [-v] [-h]"
    echo "Options:"
    echo "  -u <username>    Admin username"
    echo "  -p <password>    Admin password"
    echo "  -n <hostname>    Machine hostname"
    echo "  -d <domain>      Machine domain"
    echo "  -i <iso_url>     ISO download URL"
    echo "  -s <sign_key>    ISO pgp sign key"
    echo "  -v               Enable verbose mode"
    echo "  -h               Display this help message"
}

username="janitor"
password="$(pwgen -ns 16 1)"
hostname="machine"
domain="example.org"
iso_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.2.0-amd64-netinst.iso"
sign_key="DA87E80D6294BE9B"

while getopts u:p:n:d:i:s:vh opt; do
    case $opt in
    u) username="$OPTARG" ;;
    p) password="$OPTARG" ;;
    n) hostname="$OPTARG" ;;
    d) domain="$OPTARG" ;;
    i) iso_url="$OPTARG" ;;
    s) sign_key="$OPTARG" ;;
    v) set -o xtrace ;;
    h) usage ; exit 0 ;;
    *) usage ; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# go to project root
cd "$(realpath "$(dirname "$(readlink -f "$0")")")"

# download
iso_file=$(basename "${iso_url}")
if [[ ! -f ${iso_file} ]]; then
    echo >&2 "Downloading iso image: ${iso_file}"
    curl --progress-bar -Lo "${iso_file}" "${iso_url}"
fi
curl -sSLO "$(dirname "${iso_url}")/SHA256SUMS"
curl -sSLO "$(dirname "${iso_url}")/SHA256SUMS.sign"

# verify
gpg --keyserver keyring.debian.org --recv "${sign_key}"
gpg --verify SHA256SUMS.sign SHA256SUMS
if ! sha256sum -c <<<"$(grep "${iso_file}" SHA256SUMS)"; then
    echo >&2 "Error: Checksum not matching for: ${iso_file}"
    exit 1
fi

workdir="$(mktemp --directory)"

# unpack iso
xorriso \
    -osirrox on \
    -dev "${iso_file}" \
    -extract "/isolinux/isolinux.cfg" "${workdir}/isolinux.cfg" \
    -extract "/isolinux/adtxt.cfg" "${workdir}/adtxt.cfg"

# set default boot entry and parameters
sed -i "s#default vesamenu.c32#default auto#" "${workdir}/isolinux.cfg"
sed -i "s#auto=true#auto=true file=/cdrom/preseed.cfg#" "${workdir}/adtxt.cfg"

# copy files to include
cp -a configs/*   "${workdir}"
cp -a installer/* "${workdir}"

# replace tokens
find "${workdir}" -type f -exec sed -i "s#@USERNAME@#${username}#" {} \;
salt="$(pwgen -ns 16 1)"
hash="$(mkpasswd -m sha-512 -S "${salt}" "${password}")"
sed -i "s#@PASSHASH@#${hash}#"     "${workdir}/preseed.cfg"
sed -i "s#@HOSTNAME@#${hostname}#" "${workdir}/preseed.cfg"
sed -i "s#@DOMAIN@#${domain}#"     "${workdir}/preseed.cfg"

# repack iso
rm -f "${iso_file//.iso/-auto.iso}"
xorriso -indev "${iso_file}" \
    -map "${workdir}/adtxt.cfg"       "/isolinux/adtxt.cfg" \
    -map "${workdir}/isolinux.cfg"    "/isolinux/isolinux.cfg" \
    -map "${workdir}/splash.png"      "/isolinux/splash.png" \
    -map "${workdir}/late.sh"         "/late.sh" \
    -map "${workdir}/preseed.cfg"     "/preseed.cfg" \
    -map "${workdir}/authorized_keys" "/configs/authorized_keys" \
    -map "${workdir}/bashrc.bash"     "/configs/bashrc.bash" \
    -map "${workdir}/issue"           "/configs/issue" \
    -map "${workdir}/motd"            "/configs/motd" \
    -map "${workdir}/sshd_config"     "/configs/sshd_config" \
    -boot_image isolinux dir=/isolinux \
    -outdev "${iso_file//.iso/-auto.iso}"

echo "user: ${username}"
echo "pass: ${password}"

rm -rf "${workdir}"
