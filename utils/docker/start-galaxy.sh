#!/usr/bin/env bash

# Docker settings
docker_image="bgruening/galaxy-stable"
docker_host="localhost"
network=""
ip=""
master_api_key=""
port=80
container_name="galaxy-server"
debug="false"


function print_usage(){
    (echo -e "\n USAGE: start-galaxy.sh [--docker-host <IP>] [--container-name <NAME>] [--master-api-key <API-KEY>]"
     echo -e "                        [--network <DOCKER_NETWORK>] [--ip <CONTAINER_ADDRESS>] [--port <GALAXY_HTTP_PORT>]"
     echo -e "                        [-h|--help]\n ") >&2
}


# parse arguments
while [ -n "$1" ]; do
    # Copy so we can modify it (can't modify $1)
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
    while [ x"$OPT" != x"-" ] ; do
            case "$OPT" in
                  --docker-host=* )
                          docker_host="${OPT#*=}"
                          ;;
                  --docker-host )
                          docker_host="$2"
                          shift
                          ;;
                  --network=* )
                          network="${OPT#*=}"
                          ;;
                  --network )
                          network="$2"
                          shift
                          ;;
                  --ip=* )
                          ip="${OPT#*=}"
                          ;;
                  --ip )
                          ip="$2"
                          shift
                          ;;
                  --port=* )
                          port="${OPT#*=}"
                          ;;
                  --port )
                          port="$2"
                          shift
                          ;;
                  --master-api-key=* )
                          master_api_key="${OPT#*=}"
                          ;;
                  --master-api-key )
                          master_api_key="$2"
                          shift
                          ;;
                  --container-name=* )
                          container_name="${OPT#*=}"
                          ;;
                  --container-name )
                          container_name="$2"
                          shift
                          ;;
                  --debug )
                        debug="true"
                        shift
                        ;;
                  -h|--help )
                        print_usage
                        exit 0
                        ;;
                  * )
                          OTHER_OPTS="$OTHER_OPTS $OPT"
                          break
                          ;;
            esac
            # Check for multiple short options
            # NOTICE: be sure to update this pattern to match valid options
            NEXTOPT="${OPT#-[cfr]}" # try removing single short opt
            if [ x"$OPT" != x"$NEXTOPT" ] ; then
                    OPT="-$NEXTOPT"  # multiple short opts, keep going
            else
                    break  # long form, exit inner loop
            fi
    done
    # move to the next param
    shift
done


# Docker options
docker_options=""
if [[ -n ${master_api_key} ]]; then
    docker_options="${docker_options}-e GALAXY_CONFIG_MASTER_API_KEY=${master_api_key}"
fi

if [[ -n ${network} ]]; then
    docker_options="${docker_options} --network ${network}"
fi

if [[ -n ${ip} ]]; then
    docker_options="${docker_options} --ip ${ip}"
fi

if [[ -n ${container_name} ]]; then
    docker_options="${docker_options} --name ${container_name}"
fi


# set the Galaxy URL
galaxy_exposed="${docker_host}:${port}"
#export GALAXY_URL=${GALAXY_URL//[[:blank:]]/}

# Build Docker command
docker_cmd="docker run -d ${docker_options} -p ${galaxy_exposed}:80 ${docker_image}"

if [[ ${debug} == "true" ]]; then
    echo -e "\nDocker Command: ${docker_cmd}"
fi

# start Dockerized Galaxy
${docker_cmd}

# wait for Galaxy
printf "\nWaiting for Galaxy @ ${GALAXY_URL} ..."
until $(curl --output /dev/null --silent --head --fail ${GALAXY_URL}); do
    printf '.'
    sleep 5
done
printf ' Started\n'

# Galaxy info
printf "\nGalaxy server running @ ${GALAXY_URL}\n"