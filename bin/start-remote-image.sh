#!/usr/bin/env bash

set -euo pipefail

function main {
	local sshHost="${1:?Must provide an ssh host}"
	local containerName="${2:?Must provide an image name (org/image:version)}"

	shift
	shift
	local additionalFlags="$@"

	local org
	local image
	local version

	IFS=: read -r tmp version <<< "$containerName"
	IFS=/ read -r org image <<< "$tmp"

	local containerId="$(ssh "$sshHost" "docker ps | grep "${image}" | awk '{print \$1}'")"
	if [[ ! -z $containerId ]]; then
		echo "Stopping previous version of ${tmp}"
		ssh "$sshHost" "docker stop ${containerId}"
		echo "Stopped ${containerId} on ${sshHost}"
	fi

	local newContainerId=$(ssh "$sshHost" "docker run --rm --detach ${additionalFlags} ${containerName}")
	echo "Started new instance of ${containerName} as ${newContainerId}"
}

main "$@"
