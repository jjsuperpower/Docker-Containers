#!/bin/bash -v

AUTHOR='jjsuperpower'
CNAME='vault-hunters3'
CVERSION='latest'

MVERSION='7.7'

# if check first arg for 'no-cache'
if [ "$1" = "no-cache" ]; then
    docker build -t $AUTHOR/$CNAME:$CVERSION --no-cache .
else
    docker build -t $AUTHOR/$CNAME:$CVERSION .
fi

# mkdir "$(pwd)/testserver"
# docker run --rm --name mc-server -v "$(pwd)/testserver":/minecraft -e MOD_VERSION=$MVERSION -e EULA=TRUE -p 25565:25565 -it $AUTHOR/$CNAME:$CVERSION