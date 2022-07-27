#!/usr/bin/env bash
# dependencies: docker

set -o errexit
set -o nounset
set -o pipefail

set -o errtrace
trap finally SIGINT SIGTERM ERR EXIT
finally() {
    trap - SIGINT SIGTERM ERR EXIT
    if [[ -f $config ]]; then rm -f "${config}"; fi
}

config=$(mktemp)
cat <<EOF >"${config}"
{
	debug
}
:80 {
	root * /var/www
	encode gzip
	file_server browse
}
EOF

container_name="caddy-$(realpath "${1:-$PWD}" | inline-detox)"
echo >&2 "Serving in docker container: ${container_name}"

docker rm --force "${container_name}" >/dev/null 2>&1
docker run \
    --name "${container_name}" \
    --interactive \
    --tty \
    --rm \
    --publish "80:80" \
    --volume "${PWD}/www:/var/www":ro \
    --volume "${config}:/etc/caddy/Caddyfile":ro \
    "caddy:2-alpine"
