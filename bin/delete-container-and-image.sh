#!/usr/bin/env bash

function main {
	local sshHost="${1:?Must provide SSH Host}"
	local currentContainer="${2:?Must provide current container name}"

	echo "# Deleting $currentContainer"
	local containerId="$(ssh "$sshHost" "docker container ls -a | grep \"$currentContainer\" | awk '{print \$1}'")"
	ssh "$sshHost" "docker container rm $containerId && docker image rm $currentContainer"
}

main "$@"
