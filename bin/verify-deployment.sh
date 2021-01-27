#!/usr/bin/env bash

set -euo pipefail

function main {
	while read -r line; do
		printf "$line"
		local output="$(curl --max-time 1 -IL "$line" 2> /dev/null)"
		local status=$(echo "$output" | grep "HTTP/" | awk '{print $2}')
		echo " -> $status"
		test $status == *2* -o $status == *3*
	done < ${VERIFY_FILE:-/dev/stdin}
}

main "$@"
