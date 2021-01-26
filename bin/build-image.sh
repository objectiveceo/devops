#!/usr/bin/env bash

readonly REMOTE_STAGING_DIRECTORY=${REMOTE_STAGING_DIRECTORY:-"staging"}
readonly DOCKER_ORG=${DOCKER_ORG:-"objectiveceo"}
readonly SSH_ROOT=${SSH_ROOT:-"bethany"}
readonly DOCKER_NETWORK=${DOCKER_NETWEORK:-"bethany"}

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

function getMaxVersion {
	local param="${1:-$(</dev/stdin)}"
	echo "$param" | sort -t. -k1,1n -k2,2n -k3,3n | tail -n1
}

function incrementPatchVersion {
	local param="${1:-$(</dev/stdin)}"
	IFS=. read -r major minor patch <<< "$param"
	((patch += 1))
	echo "${major:-0}.${minor:-0}.${patch}"
}

function getBuiltImages {
	local imageName="$1"
	docker images | grep "$imageName"
}

function getBuildNumbers {
	echo "$1" | awk '{ print $2 }'
}

function getNextBuildNumber {
	if [[ -z $1 ]]; then
		echo 1.0.0
	else
		getBuildNumbers "$1" | getMaxVersion | incrementPatchVersion
	fi
}

function gitTag {
	local version="$1"
	echo "$version" > VERSION
	git add VERSION
	git commit -m "Updating shipping version to ${version}"
	git tag "$version"
}

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

function buildImage {
	local imageName="$1"
	local dockerImageName="$2"
	local nextBuildNumber="$3"
	local outputDir="$4"

	local dockerFileName="${imageName//\//+}-${nextBuildNumber}"
	local outfile="${outputDir%/}/${dockerFileName}.tar.gz"
	
	(
		docker build -t $dockerImageName . > /dev/null
		docker save "$dockerImageName" | gzip > "$outfile"
	)
	
	echo $outfile
}

function main {
	local PROJECT_ROOT="${PROJECT_ROOT:-$(findProjectRoot)}"
	local IMAGE_NAME="${IMAGE_NAME:-$(basename "${PROJECT_ROOT}")}"
	local OUTPUT_DIR="${OUTPUT_DIR:-"${HOME}/Desktop"}"

	local matchingImages=$(getBuiltImages "$IMAGE_NAME")
	local nextBuildNumber=${BUILD_NUMBER:-$(getNextBuildNumber "$matchingImages")}

	cd "$PROJECT_ROOT"

	echo "Add tag $nextBuildNumber"
	echo gitTag "$nextBuildNumber"

	local dockerImageName=$(generateDockerImageName "$IMAGE_NAME" "$nextBuildNumber")
	
	echo "Building ${dockerImageName}"
	local imageFile=$(buildImage "$IMAGE_NAME" "$dockerImageName" "$nextBuildNumber" "$OUTPUT_DIR")
	
	waitForImage "$imageFile"
	echo "Built ${imageFile}"
}

main "$@"
