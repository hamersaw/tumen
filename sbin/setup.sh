#!/bin/bash

# compute project directory
projectdir="$(pwd)/$(dirname $0)/.."
mongodir="$projectdir/bin/mongo"

# check if already setup
if [ -d "$mongodir" ]; then
    echo "mongo directory '$mongodir' already exists"
    exit
fi

# initialize instance variables
downloaddir="$HOME/Downloads"
version="mongodb-linux-x86_64-debian10-4.2.8"

# download mongo archive
if [ ! -f "$downloaddir/$version.tgz" ]; then
    echo "----DOWNLOADING MONGO ARCHIVE----"
    wget https://fastdl.mongodb.org/linux/$version.tgz \
        --directory-prefix=$downloaddir
fi

# extract files
echo "----EXTRACTING FILES----"
tar xvf "$downloaddir/$version.tgz" -C "$downloaddir"

# copy mongo binaries and documentation
echo "----COPYING BINARIES AND DOCUMENTATION----"
mkdir -p $mongodir
find $downloaddir/$version -type f | xargs -I {} cp {} $mongodir

# cleanup
echo "----CLEANUP----"
rm -r "$downloaddir/$version"
rm "$downloaddir/$version.tgz"
