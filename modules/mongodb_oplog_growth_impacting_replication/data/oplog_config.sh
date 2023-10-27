

#!/bin/bash



# Set the ${DB_NAME} and ${OPLOG_SIZE} parameters

DB_NAME=${DB_NAME}

OPLOG_SIZE=${OPLOG_SIZE}



# Connect to the MongoDB instance and switch to the ${DB_NAME} database

mongo --eval "use $DB_NAME"



# Increase the oplog size to ${OPLOG_SIZE} MB

mongo --eval "db.adminCommand({replSetResizeOplog: 1, size: $OPLOG_SIZE})"



# Adjust the oplog retention settings to ${RETENTION_HOURS} hours

mongo --eval "db.getSiblingDB('local').setProfilingLevel(0)"

mongo --eval "db.getSiblingDB('local').createCollection('oplog.rs', {capped: true, size: $((OPLOG_SIZE*2*1024*1024)), max: 10000})"

mongo --eval "db.getSiblingDB('local').runCommand({collMod: 'oplog.rs', usePowerOf2Sizes: true})"

mongo --eval "db.getSiblingDB('local').runCommand({collMod: 'oplog.rs', indexDetails: {expireAfterSeconds: $(RETENTION_HOURS*60*60)}})"