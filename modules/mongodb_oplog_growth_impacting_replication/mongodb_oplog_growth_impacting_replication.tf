resource "shoreline_notebook" "mongodb_oplog_growth_impacting_replication" {
  name       = "mongodb_oplog_growth_impacting_replication"
  data       = file("${path.module}/data/mongodb_oplog_growth_impacting_replication.json")
  depends_on = [shoreline_action.invoke_oplog_config,shoreline_action.invoke_shard_and_configure_cluster]
}

resource "shoreline_file" "oplog_config" {
  name             = "oplog_config"
  input_file       = "${path.module}/data/oplog_config.sh"
  md5              = filemd5("${path.module}/data/oplog_config.sh")
  description      = "Increase the size of the oplog and adjust the retention settings to accommodate the write volume and replication needs of the system."
  destination_path = "/tmp/oplog_config.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "shard_and_configure_cluster" {
  name             = "shard_and_configure_cluster"
  input_file       = "${path.module}/data/shard_and_configure_cluster.sh"
  md5              = filemd5("${path.module}/data/shard_and_configure_cluster.sh")
  description      = "Implement sharding or horizontal scaling to distribute the load across multiple nodes and reduce the write volume on individual nodes."
  destination_path = "/tmp/shard_and_configure_cluster.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_oplog_config" {
  name        = "invoke_oplog_config"
  description = "Increase the size of the oplog and adjust the retention settings to accommodate the write volume and replication needs of the system."
  command     = "`chmod +x /tmp/oplog_config.sh && /tmp/oplog_config.sh`"
  params      = ["RETENTION_HOURS","OPLOG_SIZE"]
  file_deps   = ["oplog_config"]
  enabled     = true
  depends_on  = [shoreline_file.oplog_config]
}

resource "shoreline_action" "invoke_shard_and_configure_cluster" {
  name        = "invoke_shard_and_configure_cluster"
  description = "Implement sharding or horizontal scaling to distribute the load across multiple nodes and reduce the write volume on individual nodes."
  command     = "`chmod +x /tmp/shard_and_configure_cluster.sh && /tmp/shard_and_configure_cluster.sh`"
  params      = ["MONGODB_CONFIG_SERVER_ADDRESS","MONGODB_COLLECTION_NAME","MONGODB_DATABASE_NAME","MONGODB_SHARD_ADDRESS","SHARD_KEY_FIELD"]
  file_deps   = ["shard_and_configure_cluster"]
  enabled     = true
  depends_on  = [shoreline_file.shard_and_configure_cluster]
}

