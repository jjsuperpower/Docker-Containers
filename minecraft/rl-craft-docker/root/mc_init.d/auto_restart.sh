#!/bin/bash

# restarts the server every day
# this is recomended by rl-craft
# the restart time is UTC
while true; do
    time=$(date +"%H:%M")
    if [ ${time} = ${RESTART_TIME} ]; then
        echo "Stopping server in 60 seconds..."
        sleep 60                                    # wait 60 seconds before restarting, so it can only start one time per day
        echo "Stopping server..."
        pkill --signal 15 java                      # kill java with SIGTERM
    fi

    sleep 59    # sleep 59 seconds

done