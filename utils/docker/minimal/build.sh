#!/usr/bin/env bash

# set prefix for distinguishing minimal from develop image (used by the 'set-docker-image-info' script)
IMAGE_NAME=${1:-"wft4galaxy"}

# absolute path of the current script
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# set git && image info
source ${script_path}/../set-git-repo-info.sh "$@"
source ${script_path}/../set-docker-image-info.sh ${IMAGE_NAME}

# Need to cd into this script's directory because image-config assumes it's running within it
cd "${script_path}"

# build the Docker image
docker build --build-arg git_branch=${GIT_BRANCH} --build-arg git_url=${GIT_HTTPS} -t ${IMAGE} .

# restore the original path
cd -
