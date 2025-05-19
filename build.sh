#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

usage() {
    echo "Usage: $0 [-u username] [-p password] [-n hostname] [-d domain] [-a package] [-i iso_url] [-s sign_key] [-o path] [-x] [-z] [-v] [-h]"
    echo "Options:"
    echo "  -u <username>    Admin username"
    echo "  -p <password>    Admin password"
    echo "  -n <hostname>    Machine hostname"
    echo "  -d <domain>      Machine domain"
    echo "  -a <package>     Additional apt package"
    echo "  -i <iso_url>     ISO download URL"
    echo "  -s <sign_key>    ISO pgp sign key"
    echo "  -o <out_file>    ISO output file"
    echo "  -x               Power off after install"
    echo "  -z               Sudo without password"
    echo "  -v               Enable verbose mode"
    echo "  -h               Display this help message"
}

username="janitor"
password="$(pwgen -ns 16 1)"
password_mask="false"
hostname="undefined"
domain="home.arpa"
iso_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso"
sign_key="DA87E80D6294BE9B"
out_file="$(basename "${iso_url}" | sed 's/netinst/auto/')"
apt_pkgs=()
poweroff=""
sudonopw=""

while getopts u:p:n:d:a:i:s:o:xzvh opt; do
    case $opt in
    u) username="$OPTARG" ;;
    p) password="$OPTARG" ; password_mask="true" ;;
    n) hostname="$OPTARG" ;;
    d) domain="$OPTARG" ;;
    a) apt_pkgs+=("$OPTARG") ;;
    i) iso_url="$OPTARG" ;;
    s) sign_key="$OPTARG" ;;
    o) out_file="$OPTARG" ;;
    x) poweroff="true" ;;
    z) sudonopw="true" ;;
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

# generate password hash
salt="$(pwgen -ns 16 1)"
passhash="$(mkpasswd -m sha-512 -S "${salt}" "${password}")"
if test "${password_mask}" == "true"; then
    password="$(echo "${password}" | tr '[:print:]' 'x')"
fi

# replace tokens
replace_token() {
    find "${workdir}" -type f -exec sed -i "s#${1}#${2}#" {} \;
}
replace_token "@USERNAME@" "${username}"
replace_token "@PASSHASH@" "${passhash}"
replace_token "@HOSTNAME@" "${hostname}"
replace_token "@DOMAIN@"   "${domain}"
replace_token "@PACKAGES@" "${apt_pkgs[*]}"

# add poweroff option
if test "${poweroff}" = "true"; then
    replace_token "@POWEROFF@" "true"
else
    replace_token "@POWEROFF@" "false"
fi

# add sudo no-password option
if test "${sudonopw}" = "true"; then
    replace_token "@SUDONOPW@" "true"
else
    replace_token "@SUDONOPW@" "false"
fi

# clear existing output iso file
if test -f "${out_file}"; then
    rm -f "${out_file}"
fi

# with no authorized keys, create dummy file
if test ! -f "${workdir}/authorized_keys"; then
    echo -n >"${workdir}/authorized_keys"
fi

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
    -outdev "${out_file}"

echo "user: ${username}"
echo "pass: ${password}"

if test "${password_mask}" == "false"; then
    printf "user: %s\npass: %s\n" "${username}" "${password}" > "${out_file}.auth"
fi

rm -rf "${workdir}"

sha256sum "${out_file}" >"${out_file}.sum"
