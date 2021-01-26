#!/usr/bin/env bash

function pushImage {
	local imageFile="$1"
	scp "$imageFile" "$SSH_ROOT":"$REMOTE_STAGING_DIRECTORY"
	echo "${REMOTE_STAGING_DIRECTORY}/$(basename "$imageFile")"
}

function main {
	local gzippedImagePath="${1:?You must provide a path to a file, preferrably gzipped.}"

	local destination="${2}"
	if [[ -z $destination ]]; then
		local hosts=$(cat ~/.ssh/config | grep "Host " | awk '{print $2}')
		echo "Enter an SSH server+path (here are some saved hosts):"
		for h in ${hosts[@]}; do
			echo "	$h"
		done
		printf "SSH destination (\`host:path/to/directory\`): "
		read destination
	fi

	echo "Pushing $gzippedImagePath to $destination"
	echo "Done"
	
	echo "$destination"
}

main "$@"
