
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# MongoDB Oplog Growth Impacting Replication
---

This incident type refers to a situation where the MongoDB Oplog, a capped collection in MongoDB that records all the write operations to a database, grows rapidly and impacts the replication process. This can occur for various reasons, such as high write volume or inefficient oplog retention settings. It can result in replication lag and failures, impacting the availability and consistency of the database.

### Parameters
```shell
export MONGODB_DATABASE_NAME="PLACEHOLDER"

export NEW_SIZE_IN_MEGABYTES="PLACEHOLDER"

export RETENTION_HOURS="PLACEHOLDER"

export OPLOG_SIZE="PLACEHOLDER"

export MONGODB_CONFIG_SERVER_ADDRESS="PLACEHOLDER"

export MONGODB_SHARD_ADDRESS="PLACEHOLDER"

export MONGODB_COLLECTION_NAME="PLACEHOLDER"

export SHARD_KEY_FIELD="PLACEHOLDER"
```

## Debug

### Check the current oplog size and usage
```shell
mongo ${MONGODB_DATABASE_NAME} --eval "printjson(db.oplog.rs.stats())"
```

### Check the current replication status and lag
```shell
mongo ${DB_NAME} --eval "printjson(rs.status())"
```

### Check the current and historical oplog growth rate
```shell
mongo ${DB_NAME} --eval "printjson(db.oplog.rs.stats(1024*1024).maxSize)"
```

### Check the oplog retention settings
```shell
mongo ${DB_NAME} --eval "printjson(db.getMongo().getDB('local').oplog.rs.options())"
```

### Optimize the oplog retention settings to reduce oplog growth
```shell
mongo ${DB_NAME} --eval "db.getMongo().getDB('local').runCommand({replSetResizeOplog: 1, size: ${NEW_SIZE_IN_MEGABYTES}})"
```

## Repair

### Increase the size of the oplog and adjust the retention settings to accommodate the write volume and replication needs of the system.
```shell


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


```

### Implement sharding or horizontal scaling to distribute the load across multiple nodes and reduce the write volume on individual nodes.
```shell


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


```