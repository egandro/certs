#!/bin/bash

if [[ ! -d /work ]]
then
    echo 'error: volume /work not monted. Please provide a directory with -v $(pwd)/certs:/work'
    exit 1
fi

if [[ ! $# -eq 2 ]] ; then
    echo "usage: $0 <hostname> <domainname>"
    echo "    example: $0 mywebserver my.localdomain"
    echo "    example: $0 "*" localnet"
    exit 1
fi

export SERVERNAME=$1
export DOMAIN=$2

# echo SERVERNAME: ${SERVERNAME}
# echo DOMAIN: ${DOMAIN}

cd /work
make -f /src/Makefile

#USER=$(stat -c '%u' /work)
#GROUP=$(stat -c '%g' /work)
#chown -R $USER:$GROUP *.pem *.zip *.deb

rm -f /work/*.yml