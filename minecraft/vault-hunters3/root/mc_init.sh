#!/bin/bash
source /mc_init.d/mc_create.sh

/bin/bash /mc_init.d/auto_chmod.sh &

# check if server.jar exists, if so do not create a new one
if [ ! -e ${MC_INST_DIR}/run.sh ]; then
    mc_create_server
fi

cd ${MC_INST_DIR}

./run.sh  Xmx${MEM_SIZE} Xms${MEM_SIZE} nogui

exit_code=$?
echo "Java exited with code ${exit_code}"
