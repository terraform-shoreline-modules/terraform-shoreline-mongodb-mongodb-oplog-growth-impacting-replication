

#!/bin/bash



# Set variables

MONGODB_CONFIG=${MONGODB_CONFIG_SERVER_ADDRESS}

MONGODB_SHARD=${MONGODB_SHARD_ADDRESS}

MONGODB_DATABASE=${MONGODB_DATABASE_NAME}

MONGODB_COLLECTION=${MONGODB_COLLECTION_NAME}

SHARD_KEY=${SHARD_KEY_FIELD}



# Enable sharding for the database

mongo --host $MONGODB_CONFIG --eval "sh.enableSharding('$MONGODB_DATABASE')"



# Create the sharded collection

mongo --host $MONGODB_CONFIG --eval "sh.shardCollection('$MONGODB_DATABASE.$MONGODB_COLLECTION', {'$SHARD_KEY': 'hashed'})"



# Add the shard to the cluster

mongo --host $MONGODB_CONFIG --eval "sh.addShard('$MONGODB_SHARD')"