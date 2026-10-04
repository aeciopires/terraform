# Common configuration of the "alb" unit: an internet-facing Application
# Load Balancer that forwards to the ECS service's target group.
#
# Module: https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/10.5.1
locals {
  # Settings from the directory hierarchy (see live/root.hcl). Found from
  # the unit's directory, because this file is included by the unit.
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment = local.env.locals.environment
  name_prefix = "${local.common.locals.prefix}-${local.environment}"
  is_floci    = local.account.locals.target == "floci"

  # floci needs one host port per listener (env.hcl); AWS uses port 80.
  listener_port = local.is_floci ? local.env.locals.floci_alb_port : 80
}

terraform {
  source = "tfr:///terraform-aws-modules/alb/aws?version=10.5.1"
}

dependency "vpc" {
  config_path = "../vpc"

  # Fake values so `plan`/`validate` work before the VPC exists.
  mock_outputs = {
    vpc_id         = "vpc-00000000"
    vpc_cidr_block = "10.0.0.0/16"
    public_subnets = ["subnet-00000001", "subnet-00000002"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  name    = "${local.name_prefix}-alb"
  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.public_subnets

  enable_deletion_protection = local.environment == "prd"

  security_group_ingress_rules = {
    http = {
      from_port   = local.listener_port
      to_port     = local.listener_port
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    vpc = {
      ip_protocol = "-1"
      cidr_ipv4   = dependency.vpc.outputs.vpc_cidr_block
    }
  }

  listeners = {
    http = {
      port     = local.listener_port
      protocol = "HTTP"
      forward  = { target_group_key = "web" }
    }
  }

  target_groups = {
    web = {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip" # Fargate tasks register by IP
      # The ECS service registers its tasks; no static attachment.
      create_attachment = false
      health_check = {
        path    = "/"
        matcher = "200"
      }
    }
  }
}
