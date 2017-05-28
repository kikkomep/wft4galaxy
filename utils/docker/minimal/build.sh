#!/usr/bin/env bash

# absolute path of the current script
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# call the build script
${script_path}/../build-image.sh -n "wft4galaxy" "minimal" "$@"