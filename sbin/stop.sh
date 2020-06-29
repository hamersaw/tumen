#!/bin/bash

usage="USAGE: $(basename $0) [OPTIONS...]
OPTIONS:
    -c <component>      mongo component to execute on
        ['all' (default), 'config, 'shard', 'router']
    -h                  display this help menu"

# parse opts
while getopts "c:h" opt; do
    case $opt in
        c)
            component=$OPTARG
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

# iterate over hosts
while read line; do
    # parse application from line
    application=$(echo $line | awk '{print $1}')

    if [ "$application" == "config" ] && \
            [ "$component" == "config" ]; then
        # stop configuration server
        echo "TODO - stop configuration server"
    elif [ "$application" == "shard" ] && \
            [ "$component" == "shard" ]; then
        # stop shard server
        echo "TODO - stop shard server"
    elif [ "$application" == "router" ] && \
            [ "$component" == "router" ]; then
        # stop query router
        echo "TODO - stop query router"
    fi
done <$hostfile
