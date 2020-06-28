# sustain
## OVERVIEW
A sample repository to setup infrastructure for the sustain project.

## USAGE
#### INSTALLATION
To install on debian execute:

    # execute setup script to install mongo binaries
    ./sbin/setup.sh

Installation on other distributions requires the 'version' variable in ethe setup.sh script to be changed to reflect the correct [MongoDB Community Server](https://www.mongodb.com/try/download/community) tar packaged release.

## REFERENCES
- https://www.linode.com/docs/databases/mongodb/build-database-clusters-with-mongodb/
#### SPATIAL QUERIES
- https://dba.stackexchange.com/questions/243476/sharding-a-mongodb-instance-by-a-spatial-key-and-a-date
- https://docs.mongodb.com/manual/geospatial-queries/
- https://docs.mongodb.com/manual/core/zone-sharding/
- https://docs.mongodb.com/manual/reference/limits/#Shard-Key-Index-Type

## LATTICE DEPLOYMENT
- hosts lattice-80 to lattice-140
#### GOALS
- sharding based on geohash
- effectively load ESRI shapefiles
- need very fast queries

## TODO
- everything
