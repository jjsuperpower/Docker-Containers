#!/bin/bash

source /mc_init.d/mc_get_server.sh

mc_create_server() {
    #check if RLC_VERSION is empty
    if [ -z "${RLC_VERSION}" ]; then
        echo "No RLC_VERSION specified, exiting"
        exit 1
    fi

    # get required urls
    get_rlcraft_url ${RLC_VERSION}
    check_versions

    download_rl_craft
    download_forge

    if [ ${REPLACE_CONFIG} ]; then
        echo 'Replacing server.properties with template file'
        mv /server.properties.template ${MC_INST_DIR}/server.properties
    fi

    echo eula=${EULA} > ${MC_INST_DIR}/eula.txt
}