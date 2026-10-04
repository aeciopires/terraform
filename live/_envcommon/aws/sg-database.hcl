# Common configuration of the "sg-database" unit: the database security
# group, which only accepts PostgreSQL from the ECS service.
#
# Module: https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/6.0.0
locals {
  # Settings from the directory hierarchy (see live/root.hcl). Found from
  # the unit's directory, because this file is included by the unit.
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment = local.env.locals.environment
  name_prefix = "${local.common.locals.prefix}-${local.environment}"
  is_floci    = local.account.locals.target == "floci"
}

terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws?version=6.0.0"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs                            = { vpc_id = "vpc-00000000" }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "ecs" {
  config_path = "../ecs"

  mock_outputs                            = { services = { web = { security_group_id = "sg-00000001" } } }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  name        = "${local.name_prefix}-db"
  description = "PostgreSQL from the ECS web service only"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_rules = {
    postgresql_from_ecs = {
      from_port                    = 5432
      to_port                      = 5432
      ip_protocol                  = "tcp"
      referenced_security_group_id = dependency.ecs.outputs.services["web"].security_group_id
      description                  = "PostgreSQL from the ECS web service"
    }
  }
}
