#!/bin/bash

usage="USAGE: $(basename $0) [OPTIONS...]
OPTIONS:
    -c <component>      mongo component to execute on
        ['config, 'shard', 'router']
    -d                  disable system authentication
    -h                  display this help menu"

# parse opts
disableauth=false
while getopts "c:dh" opt; do
    case $opt in
        c)
            component=$OPTARG
            ;;
        d)
            disableauth=true
            ;;
        h)
            echo "$usage"
            exit 0
            ;;
        ?)
            echo "$usage"
            exit 1
            ;;
    esac
done

[ -z "$component" ] && echo "set 'component' with -c option" && exit 1

# compute project directory and hostfile locations
scriptdir="$(dirname $0)"
case $scriptdir in
  /*) 
      projectdir="$scriptdir/.."
      ;;
  *) 
      projectdir="$(pwd)/$scriptdir/.."
      ;;
esac

hostfile="$projectdir/etc/hosts.txt"

# initialize instance variables
mongod="$projectdir/bin/mongod"
mongos="$projectdir/bin/mongos"

options=""
if [ ! $disableauth ]; then
    options="--auth"
fi

# iterate over nodes
nodeid=0
while read line; do
    # parse application from line
    application=$(echo $line | awk '{print $1}')

    if [ "$application" == "config" ] && \
            [ "$component" == "config" ]; then
        # ensure binary exists
        [ ! -f $mongod ] && echo "'mongod' binary not found" && exit 1

        # parse metadata
        ipaddress=$(echo $line | awk '{print $2}')
        port=$(echo $line | awk '{print $3}')
        replset=$(echo $line | awk '{print $4}')
        directory=$(echo $line | awk '{print $5}')

        logfile="$projectdir/log/node-$nodeid.log"
        pidfile="$projectdir/log/node-$nodeid.pid"

        echo "starting configuration server - $nodeid"
        if [ $ipaddress == "127.0.0.1" ]; then
            # create directory if it doesn't exist
            if [ ! -d $directory ]; then
                mkdir -p $directory
            fi

            # start application locally
            $mongod --configsvr $options --replSet $replset \
                --bind_ip $ipaddress --port $port --dbpath $directory \
                    --pidfilepath $pidfile > $logfile 2>&1 &
        else
            # start application on remote host
            echo "TODO - start remote node $nodeid"
        fi
    elif [ "$application" == "shard" ] && \
            [ "$component" == "shard" ]; then
        # ensure binary exists
        [ ! -f $mongod ] && echo "'mongod' binary not found" && exit 1

        # parse metadata
        ipaddress=$(echo $line | awk '{print $2}')
        port=$(echo $line | awk '{print $3}')
        replset=$(echo $line | awk '{print $4}')
        directory=$(echo $line | awk '{print $5}')

        logfile="$projectdir/log/node-$nodeid.log"
        pidfile="$projectdir/log/node-$nodeid.pid"

        echo "starting shard server - $nodeid"
        if [ $ipaddress == "127.0.0.1" ]; then
            # create directory if it doesn't exist
            if [ ! -d $directory ]; then
                mkdir -p $directory
            fi

            # start application locally
            $mongod --shardsvr $options --replSet $replset \
                --bind_ip $ipaddress --port $port --dbpath $directory \
                    --pidfilepath $pidfile > $logfile 2>&1 &
        else
            # start application on remote host
            echo "TODO - start remote node $nodeid"
        fi
    elif [ "$application" == "router" ] && \
            [ "$component" == "router" ]; then
        # ensure binary exists
        [ ! -f $mongos ] && echo "'mongos' binary not found" && exit 1

        # start query router
        echo "TODO - start query router"
    fi

    # increment node id
    (( nodeid += 1 ))
done <$hostfile
