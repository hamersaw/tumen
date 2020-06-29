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

while read line; do
    # parse application from line
    application=$(echo $line | awk '{print $1}')

    if [ "$application" == "config" ] && \
            [ "$component" == "config" ]; then
        # ensure binary exists
        [ ! -f $mongod ] && echo "'mongod' binary not found" && exit 1

        # start configuration server
        echo "TODO - start configuration server"
    elif [ "$application" == "shard" ] && \
            [ "$component" == "shard" ]; then
        # ensure binary exists
        [ ! -f $mongod ] && echo "'mongod' binary not found" && exit 1

        # start shard server
        echo "TODO - start shard server"
    elif [ "$application" == "router" ] && \
            [ "$component" == "router" ]; then
        # ensure binary exists
        [ ! -f $mongos ] && echo "'mongos' binary not found" && exit 1

        # start query router
        echo "TODO - start query router"
    fi
done <$hostfile
