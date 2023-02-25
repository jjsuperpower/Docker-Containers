#!/bin/bash
source /mc_init.d/mc_create.sh

/bin/bash /mc_init.d/auto_chmod.sh &

# check if server.jar exists, if so do not create a new one
if [ ! -e ${MC_INST_DIR}/server.jar ]; then
    mc_create_server
fi

/bin/bash /mc_init.d/auto_restart.sh &
auto_restart_pid=$!

cd ${MC_INST_DIR}

while true; do
    java -jar server.jar -Xmx${MEM_SIZE} -Xms${MEM_SIZE}

    exit_code=$?
    echo "Java exited with code ${exit_code}"
    echo "Starting server in 30 seconds..."
    sleep 30
done

kill -15 ${auto_restart_pid}    # kill auto restart script