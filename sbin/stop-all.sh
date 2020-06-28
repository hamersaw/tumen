#!/bin/bash

# check arguments
if [ $# != 0 ]; then
    echo "usage: $(basename $0)"
    exit
fi

# compute project directory and hostfile locations
projectdir="$(pwd)/$(dirname $0)/.."
hostfile="$projectdir/etc/hosts.txt"

# iterate over hosts
while read line; do
    # parse host
    nodeid=$(echo $line | awk '{print $1}')
    ipaddress=$(echo $line | awk '{print $3}')

    pidfile="$projectdir/log/node-$nodeid.pid"

    echo "stopping node $nodeid"
    if [ $ipaddress == "127.0.0.1" ]; then
        # stop node locally
        kill `cat $pidfile`
        rm $pidfile
    else
        # stop node on remote host
        echo "TODO - stop remote node"
        #ssh rammerd@$host -n "kill `cat $pidfile`; rm $pidfile"
    fi
done <$hostfile
