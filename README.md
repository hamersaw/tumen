# tumen
## OVERVIEW
A set of scripts to manage a mongodb cluster. 'tumen' is the name for an army unit consisting of tens of thousands of men in the Mongol army.

## USAGE
#### INSTALLATION
Download and install the distribution specific tar packaged release from [MongoDB Community Server](https://www.mongodb.com/try/download/community).

    # execute setup script to install mongo binaries
    ./tumen initialize 4.2.8
#### CONFIGURE CLUSTER
MongoDB requires configuration of replication sets and sharding schemes. tumen provides the functionality to automatically perform this configuration based on the hosts file.

    # configure cluster
    ./tumen configure mongo-admin password
#### START CLUSTER
Start the MongoDB cluster defined in etc/hosts.txt according to the official documentation, ordered configuration servers, shard servers, and then query routers.

    # start cluster
    ./tumen start
#### STOP CLUSTER
Stop to MongoDB cluster ordered by query routers, shard servers, and then configuration servers.

    # stop cluster
    ./tumen stop

## REFERENCES
- https://www.linode.com/docs/databases/mongodb/build-database-clusters-with-mongodb/

## TODO
