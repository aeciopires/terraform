# Common configuration of the "network" unit: a custom-mode VPC with one
# subnet in the unit's region and a firewall rule for internal traffic.
#
# Module: https://registry.terraform.io/modules/terraform-google-modules/network/google/18.3.0
#
# floci-gcp 0.9.0 has no Compute Engine API (it was added to floci-gcp
# after that release), so this unit is skipped on floci and only runs on a
# real project.
locals {
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.env.locals.environment
  name_prefix = "${local.common.locals.prefix}-${local.environment}"
  is_floci    = local.account.locals.target == "floci"
  project_id  = try(local.env.locals.project_id, local.account.locals.project_id)
}

# https://docs.terragrunt.com/reference/hcl/blocks/#exclude
exclude {
  if                   = local.is_floci
  actions              = ["all"]
  no_run               = true # also skip `terragrunt plan` run inside this unit
  exclude_dependencies = false
}

terraform {
  source = "tfr:///terraform-google-modules/network/google?version=18.3.0"
}

inputs = {
  project_id   = local.project_id
  network_name = "${local.name_prefix}-vpc"
  routing_mode = "REGIONAL"

  subnets = [{
    subnet_name           = "${local.name_prefix}-${local.region.locals.region}"
    subnet_ip             = local.region.locals.subnet_cidr
    subnet_region         = local.region.locals.region
    subnet_private_access = "true" # reach Google APIs without external IPs
    subnet_flow_logs      = local.environment == "prd" ? "true" : "false"
  }]

  ingress_rules = [{
    name          = "${local.name_prefix}-allow-internal"
    description   = "Traffic between instances of the subnet"
    source_ranges = [local.region.locals.subnet_cidr]
    allow         = [{ protocol = "all" }]
  }]
}
