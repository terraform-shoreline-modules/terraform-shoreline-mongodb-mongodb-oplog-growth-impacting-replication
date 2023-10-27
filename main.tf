terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "mongodb_oplog_growth_impacting_replication" {
  source    = "./modules/mongodb_oplog_growth_impacting_replication"

  providers = {
    shoreline = shoreline
  }
}