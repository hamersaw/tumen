#!/bin/bash

# check arguments
if [ $# != 0 ]; then
    echo "usage: $(basename $0)"
    exit
fi

# compute project directory and hostfile locations
projectdir="$(pwd)/$(dirname $0)/.."
hostfile="$projectdir/etc/hosts.txt"

# initialize instance variables
if [ -f "$projectdir/bin/mongo/mongod" ]; then
    mongod="$projectdir/bin/mongo/mongod"
fi

if [ -z "$mongod" ]; then
    echo "'mongod' binary not found."
    exit
fi

# start mongod servers
while read line; do
    # parse host
    nodeid=$(echo $line | awk '{print $1}')
    application=$(echo $line | awk '{print $2}')
    ipaddress=$(echo $line | awk '{print $3}')
    port=$(echo $line | awk '{print $4}')
    replset=$(echo $line | awk '{print $5}')
    directory=$(echo $line | awk '{print $6}')

    logfile="$projectdir/log/node-$nodeid.log"
    pidfile="$projectdir/log/node-$nodeid.pid"

    echo "starting node $nodeid"
    if [ $ipaddress == "127.0.0.1" ]; then
        # create directory if it doesn't exist
        if [ ! -d $directory ]; then
            mkdir -p $directory
        fi

        # start application locally
        $mongod --$application --replSet $replset \
            --bind_ip $ipaddress --port $port --dbpath $directory \
                --pidfilepath $pidfile > $logfile 2>&1 &
    else
        # start application on remote host
        echo "TODO - start remote configsvr $nodeid"
        #ssh rammerd@$host -n "RUST_LOG=debug,h2=info,hyper=info,tower_buffer=info \
        #    $application $nodeid -i $host -p $gossipport \
        #    -r $rpcport -x $xferport $options \
        #        > $projectdir/log/node-$nodeid.log 2>&1 & \
        #    echo \$! > $projectdir/log/node-$nodeid.pid"
    fi
done <$hostfile
