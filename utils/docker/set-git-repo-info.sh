#!/usr/bin/env bash

function print_usage(){
    (   echo "USAGE: $0 [--url URL] [--owner OWNER] [--branch BRANCH] [--tag TAG]"
        echo
        echo "If no arguments are provided, this script will try to get the"
        echo "required repository information from the local repository itself") >&2
}

# Initialize argument variables
git_repo_name=''
git_branch=''
git_owner=''
git_tag=''
git_url=''
OTHER_OPTS=''

# parse arguments
while [ $# -gt 0 ]; do
    OPT="$1"
    # Detect argument termination
    if [ x"$OPT" = x"--" ]; then
            shift
            for OPT ; do
                    OTHER_OPTS="$OTHER_OPTS \"$OPT\""
            done
            break
    fi
    # Parse current opt
    case "$OPT" in
      -h )
          print_usage
          exit 0
        ;;
      --repo-name=* )
          git_repo_name="${OPT#*=}"
        ;;
      --repo-name )
          [ $# -ge 2 ] || { echo "Missing value for '$1'"; exit 1; }
          git_repo_name="$2"
          shift
        ;;
      --url=* )
          git_url="${OPT#*=}"
        ;;
      --url )
          [ $# -ge 2 ] || { echo "Missing value for '$1'"; exit 1; }
          git_url="$2"
          shift
        ;;
      --owner=* )
          git_owner="${OPT#*=}"
        ;;
      --owner )
          [ $# -ge 2 ] || { echo "Missing value for '$1'"; exit 1; }
          git_owner="$2"
          shift
        ;;
      --branch=* )
          git_branch="${OPT#*=}"
        ;;
      --branch )
          [ $# -ge 2 ] || { echo "Missing value for '$1'"; exit 1; }
          git_branch="$2"
          shift
        ;;
      --tag=* )
          git_tag="${OPT#*=}"
        ;;
      --tag )
          [ $# -ge 2 ] || { echo "Missing value for '$1'"; exit 1; }
          git_tag="$2"
          shift
        ;;
      * )
          OTHER_OPTS="$OTHER_OPTS $OPT"
          break
        ;;
    esac
    # move to the next param
    shift
done

if [[ -d .git || -d $(git rev-parse --git-dir 2> /dev/null) ]]; then
    # last commit
    last_commit=$(git log --format="%H" -n 1)

    # repository URL
    if [ -z "${git_url}" ]; then
        echo "Getting git repository URL from local repository" >&2
        first_remote=$(git remote | head -n 1)
        echo "Using git remote '${first_remote}'" >&2
        if [ "${first_remote}" != "origin" ]; then
          echo "=*=*=*=*=*=*= WARNING: automatically choosing first remote in list: ${first_remote}" >&2
        fi
        git_url=$(git config --get remote.${first_remote}.url)
    fi

    # branch
    if [ -z "${git_branch}" ] ; then
        echo "Git branch not specified.  Using local repository's current branch" >&2
        git_branch=$(git rev-parse --abbrev-ref HEAD)
        git_branch=$(git branch | grep \* | cut -d ' ' -f2)
    fi

    # owner
    if [ -z "${git_owner}" ]; then
        git_owner=$(echo ${git_url} | sed -E "s/.*[:\/](.*)\/(.*)(\.git)/\1/")
    fi

    # repo name
    if [ -z "${git_repo_name}" ]; then
        git_repo_name=$(echo ${git_url} | sed -E "s/.*[:\/](.*)\/(.*)(\.git)/\2/")
    fi

    # tag
    if [ -z "${git_tag}" ]; then
        git_tag=$(git name-rev --tags --name-only $(git rev-parse HEAD))
        if [[ ${git_tag} == "undefined" ]]; then git_tag=""; fi;
    fi

    # export settings
    export GIT_LAST_COMMIT=${last_commit}
    export GIT_URL=${git_url}
    export GIT_BRANCH=${git_branch}
    export GIT_OWNER=${git_owner}
    export GIT_REPO_NAME=${git_repo_name}
    export GIT_TAG=${git_tag}
    export GIT_SSH="git@github.com:${git_owner}/${git_repo_name}.git"
    export GIT_HTTPS="https://github.com/${git_owner}/${git_repo_name}.git"

    # log git/docker info
    echo " - Git Repository URL: ${git_url}" >&2
    echo " - Git owner: ${git_owner}" >&2
    echo " - Git repo name: ${git_repo_name}" >&2
    echo " - Git branch: ${git_branch}" >&2
    echo " - Git tag : ${git_tag}" >&2
    echo " - Git last commit: ${last_commit}" >&2
    echo " - Git repo URL: ${git_url}" >&2
    echo " - Git repo URL (ssh): ${GIT_SSH}" >&2
    echo " - Git repo URL (https): ${GIT_HTTPS}" >&2
else
    echo "WARNING: this is not a Git repository" >&2
fi
