#!/usr/bin/env bash

function installImage {
	local sshRoot="$1"
	local imageFile="$2"
	local imageName=$(basename "$imageFile")
	local gunzippedName="${imageName%.gz}"
	ssh "$sshRoot" "cd \"$(dirname "$imageFile")\"; gunzip \"$(basename "$imageName")\"; docker load -i ${gunzippedName}"
}

function verifyInstallation {
	local sshHost="$1"
	local dockerImageName="$2"
	IFS=: read -r repo tag <<< "$dockerImageName"
	local found=$(ssh "$sshHost" "docker images | grep ${repo} | grep ${tag}")
	if [[ -z $found ]]; then
		return -1
	fi
}

function cleanupRemoveArchive {
	local sshHost="$1"
	local path="$2"
	# Remove tar archive (gz has already been removed)
	ssh "$sshHost" "rm \"${path%.gz}\""
}

function main {
	local destination="${1:?You must provide an SSH URL in the format of host:path/to/file}"
	local imageName="${2:?You must provide a Docker image name as well (org/container:version).}"

	local sshHost="$(echo "$destination" | sed 's/:.*//')"
	local path="$(echo "$destination" | sed 's/.*://')"

	installImage "$sshHost" "$path"
	verifyInstallation "$sshHost" "$imageName"
	if [[ $? -eq 0 ]]; then
		echo "Successfully installed ${imageName} on ${sshHost}"
		cleanupRemoveArchive "$sshHost" "$path"
		echo "Removed $path on $sshHost"
	else
		echo "Unable to verify that ${dockerImageName} was successfully installed on ${sshHost}"
		exit -1
	fi
}

main "$@"
