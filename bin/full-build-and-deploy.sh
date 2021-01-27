#!/usr/bin/env bash

set -euo pipefail

readonly BIN="$(cd "$(dirname "${BASH_SOURCE[@]}")"; pwd)"
readonly SSH_IMAGE_DESTINATION="${SSH_IMAGE_DESTINATION:?Provide SSH image destination}"

function main {
	local logfile=${LOG_FILE:-"__build.log"}
	
	"${BIN}/build-image.sh" | tee "$logfile"
	local imagePath="$(tail -n1 "$logfile")"
	
	"${BIN}/push-image.sh" "$imagePath" "$SSH_IMAGE_DESTINATION" | tee -a "$logfile"
	local remoteImage="$(tail -n1 "$logfile")"

	local imageName="$(grep Building "$logfile" | sed 's/Building //')"
	"${BIN}/install-remote-image.sh" "$remoteImage" "$imageName" | tee -a "$logfile"

	local sshHost="$(echo "$SSH_IMAGE_DESTINATION" | sed -e 's/:.*//')"
	local containerName="$(head -n1 "$logfile" | awk '{print $2}')"
	"${BIN}/start-remote-image.sh" "$sshHost" "$containerName"

	"${BIN}/verify-deployment.sh"
	if [[ $? -ne 0 ]]; then
		"${BIN}/rollback-deployment.sh"
	fi
}

main "$@"
