# Common configuration of the "vpc" unit in every AWS environment/region.
# A unit includes this file and adds only what is specific to it.
#
# Module: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/6.7.3
locals {
  # Settings from the directory hierarchy (see live/root.hcl). Found from
  # the unit's directory, because this file is included by the unit.
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment = local.env.locals.environment
  name_prefix = "${local.common.locals.prefix}-${local.environment}"
  is_floci    = local.account.locals.target == "floci"
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  cidr = local.region.locals.vpc_cidr
  azs  = local.region.locals.azs
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=6.7.3"
}

inputs = {
  name = "${local.name_prefix}-vpc"
  cidr = local.cidr
  azs  = local.azs

  # One /24 per AZ: public 10.x.0-9.0/24, private 10.x.10-19.0/24.
  public_subnets  = [for i, az in local.azs : cidrsubnet(local.cidr, 8, i)]
  private_subnets = [for i, az in local.azs : cidrsubnet(local.cidr, 8, i + 10)]

  # Private subnets reach the internet through NAT. One NAT Gateway per AZ
  # only in production (resilience); a single one elsewhere (cost).
  enable_nat_gateway = true
  single_nat_gateway = local.environment != "prd"

  enable_dns_hostnames = true
  enable_dns_support   = true

  # floci 2.1.0 does not return the IPv6/ICMP fields of the default network
  # ACL rules, so managing it shows a change on every plan. See
  # docs/04-providers-e-floci.md ("floci vs nuvem real").
  manage_default_network_acl = !local.is_floci
}
