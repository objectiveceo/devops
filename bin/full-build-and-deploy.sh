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
}

main "$@"
