# Common configuration of the "cloud-sql" unit: Cloud SQL for PostgreSQL.
# The instance gets a public IP with NO authorized networks: clients connect
# through the Cloud SQL Auth Proxy / connectors, which use IAM and TLS.
#
# Module: https://registry.terraform.io/modules/terraform-google-modules/sql-db/google/28.3.0
#
# The module reads google_compute_zones, and floci-gcp 0.9.0 has no Compute
# Engine API, so this unit is skipped on floci and only runs on a real
# project.
locals {
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.env.locals.environment
  name_prefix = "${local.common.locals.prefix}-${local.environment}"
  is_floci    = local.account.locals.target == "floci"
  is_prd      = local.environment == "prd"
}

# https://docs.terragrunt.com/reference/hcl/blocks/#exclude
exclude {
  if                   = local.is_floci
  actions              = ["all"]
  no_run               = true # also skip `terragrunt plan` run inside this unit
  exclude_dependencies = false
}

terraform {
  source = "tfr:///terraform-google-modules/sql-db/google//modules/postgresql?version=28.3.0"
}

inputs = {
  project_id = try(local.env.locals.project_id, local.account.locals.project_id)
  region     = local.region.locals.region
  name       = "${local.name_prefix}-postgres"

  database_version  = "POSTGRES_17"
  edition           = "ENTERPRISE"
  tier              = local.env.locals.sql_tier
  availability_type = local.is_prd ? "REGIONAL" : "ZONAL"

  deletion_protection         = local.is_prd
  deletion_protection_enabled = local.is_prd

  db_name   = "app"
  user_name = "app" # the module generates the password

  ip_configuration = {
    ipv4_enabled        = true
    ssl_mode            = "ENCRYPTED_ONLY"
    authorized_networks = []
  }
}
