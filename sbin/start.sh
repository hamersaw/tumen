#!/bin/bash

usage="USAGE: $(basename $0) [OPTIONS...]
OPTIONS:
    -c <component>      mongo component to execute on
        ['config, 'shard', 'router']
    -s                  start in 'setup' mode - disabled authentication
    -h                  display this help menu"

# parse opts
setup=false
while getopts "c:hs" opt; do
    case $opt in
        c)
            component=$OPTARG
            ;;
        h)
            echo "$usage"
            exit 0
            ;;
        s)
            setup=true
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
keyfile="$projectdir/etc/keyfile"

# initialize instance variables
mongod="$projectdir/bin/mongod"
mongos="$projectdir/bin/mongos"

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

        [ "$setup" == false ] && options="--auth --keyFile $keyfile"

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
            ssh rammerd@$host -n "[ ! -d $directory ] && mkdir -p $direcotry; \
                $mongod --configsvr $options --replSet $replset \
                --bind_ip $ipaddress --port $port --dbpath $directory \
                    --pidfilepath $pidfile > $logfile 2>&1 &"
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

        [ "$setup" == false ] && options="--auth --keyFile $keyfile"

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
            ssh rammerd@$host -n "[ ! -d $directory ] && mkdir -p $direcotry; \
                $mongod --shardsvr $options --replSet $replset \
                --bind_ip $ipaddress --port $port --dbpath $directory \
                    --pidfilepath $pidfile > $logfile 2>&1 &"
        fi
    elif [ "$application" == "router" ] && \
            [ "$component" == "router" ]; then
        # ensure binary exists
        [ ! -f $mongos ] && echo "'mongos' binary not found" && exit 1

        # parse metadata
        ipaddress=$(echo $line | awk '{print $2}')
        port=$(echo $line | awk '{print $3}')
        directory=$(echo $line | awk '{print $4}')

        logfile="$projectdir/log/node-$nodeid.log"
        pidfile="$projectdir/log/node-$nodeid.pid"

        # compile configdb
        replset=$(cat $hostfile | grep 'config' \
            | awk '{print $4}' | sort | uniq | head -n 1)
        while read line; do
            # parse ip address and port from line
            configip=$(echo $line | awk '{print $2}')
            configport=$(echo $line | awk '{print $3}')

            # append to members
            [ ! -z "$members" ] && members="$members,"
            members="$members$configip:$configport"
        done < <(grep "$replset" $hostfile)

        configdb="$replset/$members"

        [ "$setup" == false ] && options="--keyFile $keyfile"

        echo "starting query router - $nodeid"
        if [ $ipaddress == "127.0.0.1" ]; then
            # start application locally
            $mongos $options --bind_ip $ipaddress --port $port \
                --configdb "$configdb" --pidfilepath $pidfile \
                    > $logfile 2>&1 &
        else
            # start application on remote host
            ssh rammerd@$host -n "$mongos $options --bind_ip $ipaddress \
                --port $port --configdb "$configdb" \
                --pidfilepath $pidfile > $logfile 2>&1 &"
        fi
    fi

    # increment node id
    (( nodeid += 1 ))
done <$hostfile
