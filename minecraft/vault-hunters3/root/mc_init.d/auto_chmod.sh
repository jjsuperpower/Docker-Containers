#!/bin/bash

# this is needed if using bind mount, to make files writeable
# its hacky, but it works
while true; do
    chmod -R guo+rw ${MC_INST_DIR}
    sleep 120
    # chmod 777 $(find ${MC_INST_DIR} -maxdepth 10 -type d | sed -e "s/'/'\\\\''/g;s/\(.*\)/'\1'/")       # the sed horror show is from stack exchange, long story short, don't put spaces in file names
    # chmod 666 $(find ${MC_INST_DIR} -maxdepth 10 -type f | sed -e "s/'/'\\\\''/g;s/\(.*\)/'\1'/")       # https://stackoverflow.com/questions/1616577/surround-all-lines-in-a-text-file-with-quotes-something
done