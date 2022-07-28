#!/usr/bin/env bash
# dependencies: curl xorriso

set -o errexit
set -o nounset
set -o pipefail

iso_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.4.0-amd64-netinst.iso"
iso_md5="d78b390d70e4a858b41d6bdfdd4b27a0"

log() {
    echo >&2 "$*"
}

# download iso
iso_file=$(basename ${iso_url})
if [[ ! -f ${iso_file} ]]; then
    log "Downloading iso image: ${iso_file}"
    curl --location --remote-name ${iso_url}
fi

# verify iso checksum
if ! md5sum -c <<<"${iso_md5} ${iso_file}" | grep -q "${iso_file}: OK"; then
    log "Error: Checksum not matching for: ${iso_file}"
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
sed -i "s#default .*#default auto#" "${workdir}/isolinux.cfg"
sed -i "s#timeout .*#timeout 10#" "${workdir}/isolinux.cfg"
sed -i "s#auto=.*#auto=true url=https://nothub.github.io/debian-autoinstall/preseed.cfg#" "${workdir}/adtxt.cfg"

# repack iso
rm -f "${iso_file//.iso/-auto.iso}"
xorriso -indev "${iso_file}" \
    -map "${workdir}/isolinux.cfg" "/isolinux/isolinux.cfg" \
    -map "${workdir}/adtxt.cfg" "/isolinux/adtxt.cfg" \
    -boot_image isolinux dir=/isolinux \
    -outdev "${iso_file//.iso/-auto.iso}"

rm -rf "${workdir}"
