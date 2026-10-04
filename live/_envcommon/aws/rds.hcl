# Common configuration of the "rds" unit: RDS for PostgreSQL in the private
# subnets. The master password is generated and stored by RDS in AWS
# Secrets Manager (the module's default, manage_master_user_password).
#
# Module: https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/7.2.2
locals {
  # Settings from the directory hierarchy (see live/root.hcl). Found from
  # the unit's directory, because this file is included by the unit.
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment = local.env.locals.environment
  name_prefix = "${local.common.locals.prefix}-${local.environment}"
  is_floci    = local.account.locals.target == "floci"

  is_prd = local.environment == "prd"
}

terraform {
  source = "tfr:///terraform-aws-modules/rds/aws?version=7.2.2"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs                            = { private_subnets = ["subnet-00000003", "subnet-00000004"] }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "sg" {
  config_path = "../sg-database"

  mock_outputs                            = { id = "sg-00000002" }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  identifier = "${local.name_prefix}-postgres"

  engine               = "postgres"
  engine_version       = "17"
  family               = "postgres17" # DB parameter group
  major_engine_version = "17"         # DB option group
  instance_class       = local.env.locals.db_instance_class
  allocated_storage    = 20

  db_name  = "app"
  username = "app"
  port     = 5432

  create_db_subnet_group = true
  subnet_ids             = dependency.vpc.outputs.private_subnets
  vpc_security_group_ids = [dependency.sg.outputs.id]

  multi_az                = local.is_prd
  deletion_protection     = local.is_prd
  skip_final_snapshot     = !local.is_prd
  backup_retention_period = local.is_prd ? 7 : 1
}
