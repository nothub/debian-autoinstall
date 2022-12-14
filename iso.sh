#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

debian_signing_key="DA87E80D6294BE9B"
iso_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.5.0-amd64-netinst.iso"

# download
iso_file=$(basename ${iso_url})
if [[ ! -f ${iso_file} ]]; then
    echo >&2 "Downloading iso image: ${iso_file}"
    curl --progress-bar --location --remote-name ${iso_url}
fi
curl --silent --location --remote-name "$(dirname ${iso_url})/SHA256SUMS"
curl --silent --location --remote-name "$(dirname ${iso_url})/SHA256SUMS.sign"

# verify
gpg --keyserver keyring.debian.org --recv "${debian_signing_key}"
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
sed -i "s#auto=true#auto=true url=https://nothub.github.io/debian-autoinstall/preseed.cfg#" "${workdir}/adtxt.cfg"

# repack iso
rm -f "${iso_file//.iso/-auto.iso}"
xorriso -indev "${iso_file}" \
    -map "${workdir}/isolinux.cfg" "/isolinux/isolinux.cfg" \
    -map "${workdir}/adtxt.cfg" "/isolinux/adtxt.cfg" \
    -boot_image isolinux dir=/isolinux \
    -outdev "${iso_file//.iso/-auto.iso}"

rm -rf "${workdir}"
