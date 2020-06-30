# tumen
## OVERVIEW
A set of scripts to manage a mongodb cluster. 'tumen' is the name for an army unit consisting of tens of thousands of men in the Mongol army.

## USAGE
#### INSTALLATION
To install on debian execute:

    # execute setup script to install mongo binaries
    ./tumen initialize

Installation on other distributions requires the 'version' variable in ethe tumen script to be changed to reflect the correct [MongoDB Community Server](https://www.mongodb.com/try/download/community) tar packaged release.
#### CONFIGURE CLUSTER
MongoDB requires configuration of replication sets and sharding schemes. tumen provides the functionality to automatically perform this configuration based on the hosts file.

    # configure cluster
    ./tumen configure
#### START CLUSTER
    # start cluster
    ./tumen start
#### STOP CLUSTER
    # stop cluster
    ./tumen stop

## REFERENCES
- https://www.linode.com/docs/databases/mongodb/build-database-clusters-with-mongodb/

## TODO
- pass admin username and password on 'configure'
