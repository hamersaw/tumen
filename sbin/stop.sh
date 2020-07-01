#!/bin/bash

usage="USAGE: $(basename $0) [OPTIONS...]
OPTIONS:
    -c <component>      mongo component to execute on
        ['all' (default), 'config, 'shard', 'router']
    -h                  display this help menu"

# parse opts
while getopts "c:hp:u:" opt; do
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
mongo="$projectdir/bin/mongo"

# iterate over nodes
nodeid=0
while read line; do
    # parse application from line
    application=$(echo $line | awk '{print $1}')

    # parse metadata
    ipaddress=$(echo $line | awk '{print $2}')
    port=$(echo $line | awk '{print $3}')

    pidfile="$projectdir/log/node-$nodeid.pid"

    if [ "$application" == "config" ] && \
            [ "$component" == "config" ]; then
        # stop configuration server
        echo "stopping configuration server - $nodeid"
        if [ $ipaddress == "127.0.0.1" ]; then
            # stop node locally
            kill `cat $pidfile`
            rm $pidfile
        else
            # stop node on remote host
            ssh rammerd@$host -n "kill `cat $pidfile`; rm $pidfile"
        fi
    elif [ "$application" == "shard" ] && \
            [ "$component" == "shard" ]; then
        # stop shard server
        echo "stopping shard server - $nodeid"
        if [ $ipaddress == "127.0.0.1" ]; then
            # stop node locally
            kill `cat $pidfile`
            rm $pidfile
        else
            # stop node on remote host
            ssh rammerd@$host -n "kill `cat $pidfile`; rm $pidfile"
        fi
    elif [ "$application" == "router" ] && \
            [ "$component" == "router" ]; then
        # stop query router
        echo "stopping query router - $nodeid"
        if [ $ipaddress == "127.0.0.1" ]; then
            # stop node locally
            kill `cat $pidfile`
            rm $pidfile
        else
            # stop node on remote host
            ssh rammerd@$host -n "kill `cat $pidfile`; rm $pidfile"
        fi
    fi

    # increment node id
    (( nodeid += 1 ))
done <$hostfile
