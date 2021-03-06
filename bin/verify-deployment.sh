#!/usr/bin/env bash

set -eo pipefail

function main {
	echo "Taking a brief respite to let everything set up"
	sleep 2
	echo

	if [[ -f "$VERIFY_FILE" ]]; then
		echo "Running verification using $VERIFY_FILE"
	else
		echo "Running verification using stdin"
	fi

	while read -r line; do
		IFS=' ' read -r url expected <<< $line
		printf "$url (expecting $expected)"
		local output="$(curl --max-time 1 -I "$url" 2> /dev/null)"
		local status=$(echo "$output" | grep "HTTP/" | awk '{print $2}')
		echo " -> $status"
		test "$status" = "$expected"
	done < ${VERIFY_FILE:-/dev/stdin}
}

main "$@"
