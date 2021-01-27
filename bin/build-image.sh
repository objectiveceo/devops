#!/usr/bin/env bash

readonly REMOTE_STAGING_DIRECTORY=${REMOTE_STAGING_DIRECTORY:-"staging"}
readonly DOCKER_ORG=${DOCKER_ORG:-"objectiveceo"}
readonly SSH_ROOT=${SSH_ROOT:-"objectiveceo"}
readonly OUTPUT_DIR="${OUTPUT_DIR:-"${HOME}/Desktop"}"
readonly BUILD_NUMBER=${BUILD_NUMBER:-"X"}

function findProjectRoot {
	local root="$(pwd)"
	while [[ true ]]; do
		local dockerfile="${root%/}/Dockerfile"
		if [[ -e "$dockerfile" ]]; then
			break;
		fi

		root="$(dirname "$root")"
		if [[ $root = / ]]; then
			break
		fi
	done
	echo "$root"
}

readonly PROJECT_ROOT="${PROJECT_ROOT:-$(findProjectRoot)}"
readonly IMAGE_NAME="${IMAGE_NAME:-$(basename "${PROJECT_ROOT}")}"

function waitForImage {
	local imageFile="$1"
	local retryCount=0

	while [[ $retryCount -lt 10 && ! -f "$imageFile" ]]; do
		echo "Waiting for ${imageFile} [$((retryCount + 1)) of 10]"
		sleep 1
		((retryCount += 1))
	done
}

function generateDockerImageName {
	local imageName="$1"
	local nextBuildNumber="$2"
	echo "${DOCKER_ORG}/${imageName}:${nextBuildNumber}"
}

function main {
	cd "$PROJECT_ROOT"

	local dockerImageName=$(generateDockerImageName "$IMAGE_NAME" "$BUILD_NUMBER")
	
	echo "Building ${dockerImageName}"
	if [[ ! -d "$OUTPUT_DIR" ]]; then
		mkdir -p "$OUTPUT_DIR"
	fi

	local imageFile="${OUTPUT_DIR%/}/${IMAGE_NAME//\//+}-${BUILD_NUMBER}.tar.gz"
	docker build \
		--build-arg build_number=${BUILD_NUMBER} \
		-t $dockerImageName . | tee "${LOG_FILE:-docker_build.log}"
	docker save "$dockerImageName" | gzip > "$imageFile"

	waitForImage "$imageFile"
	if [[ ! -f "$imageFile" ]]; then
		echo "$imageFile was not built; exiting."
		exit -1
	fi

	echo "Done"
	echo "${imageFile}"
}

main "$@"
