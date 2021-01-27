#!/usr/bin/env bash

readonly BIN="$(cd "$(dirname "${BASH_SOURCE[@]}")"; pwd)"

function main {
	local sshHost="${1:?Must provide SSH Host}"
	local currentContainer="${2:?Must provide current container name}"

	echo "#########################"
	echo "# Error -> Rolling back #"
	echo "#########################"

	local imagesLine="$(ssh "$sshHost" "docker images --filter \"before=$currentContainer\"" | head -n2 | tail -n1)"
	local name="$(awk '{print $1}' <<< $imagesLine)"
	local version="$(awk '{print $2}' <<< $imagesLine)"
	local previousContainer="${name}:${version}"

	echo "# Restoring $previousContainer"
	 "${BIN}/start-remote-image.sh" "$sshHost" "$previousContainer"
}

main "$@"
